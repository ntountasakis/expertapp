import {getCallTransactionDocumentRef, getPrivateUserDocument} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/firebase/firestore/models/call_transaction";
import {PrivateUserInfo} from "../../../../../../../shared/firebase/firestore/models/private_user_info";
import {calculateCostOfCallInCents} from "../../util/call_cost_calculator";
import {markCallEnd} from "../../util/call_transaction_complete";
import {paymentIntentHelperFunc, PaymentIntentType} from "../../util/payment_intent_helper";
import {EndCallTransactionReturnType} from "../types/call_transaction_types";

export const endCallTransactionCallerCommon = async (
    {callTransaction, transaction} :
    {callTransaction: CallTransaction, transaction: FirebaseFirestore.Transaction}):
    Promise<EndCallTransactionReturnType> => {
  // todo: unify with call transaction end time
  const endTimeUtcMs = Date.now();
  const costOfCallInCents = calculateCostOfCallInCents({
    beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs,
    endTimeUtcMs: endTimeUtcMs,
    centsPerMinute: callTransaction.expertRateCentsPerMinute,
  });
  const privateCallerUserInfo: PrivateUserInfo = await getPrivateUserDocument(
      {transaction: transaction, uid: callTransaction.callerUid});

  const paymentIntentResult: PaymentIntentType = await paymentIntentHelperFunc(
      {costInCents: costOfCallInCents, privateUserInfo: privateCallerUserInfo,
        uid: callTransaction.callerUid, transferGroup: callTransaction.callerTransferGroup, transaction: transaction,
        description: "End Call"});

  if (typeof paymentIntentResult === "string") {
    throw new Error(`Error procesing paymentIntent. ${paymentIntentResult}`);
  }
  const [paymentStatusId, paymentIntentClientSecret] = paymentIntentResult;

  updateCallTransactionTerminateFields(callTransaction, paymentStatusId, transaction);
  if (!callTransaction.callHasEnded) {
    markCallEnd(callTransaction.callTransactionId, endTimeUtcMs, transaction);
  }

  console.log(`Cost of Call for talk-time: ${costOfCallInCents}`);

  return [callTransaction.callTransactionId, paymentIntentClientSecret,
    paymentStatusId, privateCallerUserInfo.stripeCustomerId];
};

function updateCallTransactionTerminateFields(callTransaction: CallTransaction,
    callTerminatePaymentStatusId: string, transaction: FirebaseFirestore.Transaction) {
  const callTransactionRef = getCallTransactionDocumentRef({transactionId: callTransaction.callTransactionId});
  transaction.update(callTransactionRef, {
    "callerCallTerminatePaymentStatusId": callTerminatePaymentStatusId,
  });
}
