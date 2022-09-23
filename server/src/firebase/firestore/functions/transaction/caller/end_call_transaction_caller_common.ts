import {CallTransaction} from "../../../models/call_transaction";
import {calculateCostOfCallInCents} from "../../util/call_cost_calculator";
import {markCallEndIfNotAlready} from "../../util/call_transaction_complete";
import {getCallTransactionRef, getPrivateUserInfo} from "../../util/model_fetchers";
import {paymentIntentHelperFunc, PaymentIntentType} from "../../util/payment_intent_helper";
import {EndCallTransactionReturnType} from "../types/call_transaction_types";

export const endCallTransactionCallerCommon = async (
    {callTransaction, transaction} :
    {callTransaction: CallTransaction, transaction: FirebaseFirestore.Transaction}):
    Promise<EndCallTransactionReturnType> => {
  const endTimeUtcMs = Date.now();
  const costOfCallInCents = calculateCostOfCallInCents({
    beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs,
    endTimeUtcMs: endTimeUtcMs,
    centsPerMinute: callTransaction.expertRateCentsPerMinute,
  });

  const [privateCallerInfoErrorMessage, privateCallerUserInfo] = await getPrivateUserInfo(
      callTransaction.callerUid, transaction);
  if (privateCallerInfoErrorMessage !== "" || privateCallerUserInfo === undefined) {
    return failure(privateCallerInfoErrorMessage);
  }

  const paymentIntentResult: PaymentIntentType = await paymentIntentHelperFunc(
      {costInCents: costOfCallInCents, privateUserInfo: privateCallerUserInfo,
        uid: callTransaction.callerUid, transaction: transaction,
        description: "End Call"});

  if (typeof paymentIntentResult === "string") {
    return failure(paymentIntentResult);
  }
  const [paymentStatusId, paymentIntentClientSecret] = paymentIntentResult;

  updateCallTransactionTerminateFields(callTransaction, paymentStatusId, transaction);
  markCallEndIfNotAlready(callTransaction, endTimeUtcMs, transaction);

  console.log(`Cost of Call: ${costOfCallInCents}`);

  return [callTransaction.callTransactionId, paymentIntentClientSecret,
    paymentStatusId, privateCallerUserInfo.stripeCustomerId];
};

function failure(errorMessage: string): EndCallTransactionReturnType {
  console.error(`Error in EndCallTransaction: ${errorMessage}`);
  return errorMessage;
}

function updateCallTransactionTerminateFields(callTransaction: CallTransaction,
    callTerminatePaymentStatusId: string, transaction: FirebaseFirestore.Transaction) {
  const callTransactionRef = getCallTransactionRef(callTransaction.callTransactionId);
  transaction.update(callTransactionRef, {
    "callerCallTerminatePaymentStatusId": callTerminatePaymentStatusId,
  });
}
