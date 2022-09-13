import * as admin from "firebase-admin";
import {ClientCallTerminateRequest} from "../../../protos/call_transaction_package/ClientCallTerminateRequest";
import {calculateCostOfCallInCents} from "./util/call_cost_calculator";
import {getCallTransaction, getPrivateUserInfo} from "./util/model_fetchers";
import {paymentIntentHelperFunc, PaymentIntentType} from "./util/payment_intent_helper";

/* algorithm todo:
    1) mark call end time in transaction -- done
    2) calculate cost of call -- done
    3) create stripe payment intent with these details -- done
    4) create new message type and have client pay
    5) pay expert
    */

export type EndCallTransactionReturnType = [
  endCallTransactionId: string,
  endCallPaymentIntentClientSecret: string,
  endCallPaymentIntentPaymentStatusId: string,
  callerStripeCustomerId: string] | string;

export const endCallTransactionClientInitiated = async (
    {terminateRequest}: {terminateRequest: ClientCallTerminateRequest}): Promise<EndCallTransactionReturnType> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    if (terminateRequest.callTransactionId == null || terminateRequest.uid == null) {
      const errorMessage = `Invalid ClientCallTerminateRequest, either ids are null.
      CallTransactionId: ${terminateRequest.callTransactionId} Uid: ${terminateRequest.uid}`;
      return endCallTransactionFailure(errorMessage);
    }
    const [privateCallerInfoErrorMessage, privateCallerUserInfo] = await getPrivateUserInfo(
        terminateRequest.uid, transaction);
    if (privateCallerInfoErrorMessage !== "" || privateCallerUserInfo === undefined) {
      return endCallTransactionFailure(privateCallerInfoErrorMessage);
    }
    const [callTransactionLookupErrorMessage, callTransaction] = await getCallTransaction(
        terminateRequest.callTransactionId, transaction);
    if (callTransactionLookupErrorMessage !== "" || callTransaction === undefined) {
      return endCallTransactionFailure(callTransactionLookupErrorMessage);
    }

    if (terminateRequest.uid !== callTransaction.callerUid) {
      const errorMessage = `Uid: ${terminateRequest.uid} cannot terminate call: ${callTransaction.callerUid} 
      because they are not the caller`;
      endCallTransactionFailure(errorMessage);
    }

    if (callTransaction.callHasEnded || callTransaction.callEndTimeUtsMs !== 0) {
      const errorMessage = `Uid: ${terminateRequest.uid} cannot terminate call: ${callTransaction.callerUid} 
      because is already terminate`;
      endCallTransactionFailure(errorMessage);
    }

    const endTimeUtcMs = Date.now();
    const costOfCallInCents = calculateCostOfCallInCents({
      beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs,
      endTimeUtcMs: endTimeUtcMs,
      centsPerMinute: callTransaction.expertRateCentsPerMinute,
    });

    const paymentIntentResult: PaymentIntentType = await paymentIntentHelperFunc(
        {costInCents: costOfCallInCents, privateUserInfo: privateCallerUserInfo,
          uid: terminateRequest.uid, transaction: transaction,
          description: "End Call"});

    if (typeof paymentIntentResult === "string") {
      return endCallTransactionFailure(paymentIntentResult);
    }
    const [paymentStatusId, paymentIntentClientSecret] = paymentIntentResult;

    updateCallTransactionTerminateFields(callTransaction.callTransactionId, paymentStatusId, endTimeUtcMs, transaction);

    console.log(`Cost of Call: ${costOfCallInCents}`);
    console.log(`CallTransactionTerminationRequest: ${callTransaction.callTransactionId} serviced`);

    return [callTransaction.callTransactionId, paymentIntentClientSecret,
      paymentStatusId, privateCallerUserInfo.stripeCustomerId];
  });
};

function updateCallTransactionTerminateFields(callTransactionId: string,
    callTerminatePaymentStatusId: string, callEndTimeUtsMs: number, transaction: FirebaseFirestore.Transaction) {
  const callTransactionRef = admin.firestore().collection("call_transactions").doc(callTransactionId);
  transaction.update(callTransactionRef, {
    "callerCallTerminatePaymentStatusId": callTerminatePaymentStatusId,
    "callHasEnded": true,
    "callEndTimeUtsMs": callEndTimeUtsMs,
  });
}

function endCallTransactionFailure(errorMessage: string): EndCallTransactionReturnType {
  console.error(`Error in EndCallTransaction: ${errorMessage}`);
  return errorMessage;
}
