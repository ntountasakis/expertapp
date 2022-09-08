import * as admin from "firebase-admin";
import {ClientCallTerminateRequest} from "../../../protos/call_transaction_package/ClientCallTerminateRequest";
import {CallTransaction} from "../models/call_transaction";
import {getCallTransaction, getPrivateUserInfo} from "./util/utils";

type EndCallTransactionReturnType = [valid: boolean, errorMessage: string, endCallPaymentIntentClientSecret: string,
callerStripeCustomerId: string, transaction: CallTransaction | undefined];

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

    /* algorithm todo:
    1) mark call end time in transaction
    2) calculate cost of call
    3) create stripe payment intent with these details
    4) create new message type and have client pay
    5) pay expert
    */

    return endCallTransactionFailure(""); // todo remove
  });
};

function endCallTransactionFailure(errorMessage: string): EndCallTransactionReturnType {
  console.error(`Error in EndCallTransaction: ${errorMessage}`);
  return [false, errorMessage, "", "", undefined];
}
