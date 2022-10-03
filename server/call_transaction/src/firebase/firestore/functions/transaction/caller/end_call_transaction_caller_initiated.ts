import * as admin from "firebase-admin";
import {ClientCallTerminateRequest} from "../../../../../protos/call_transaction_package/ClientCallTerminateRequest";
import {getCallTransaction} from "../../util/model_fetchers";
import {EndCallTransactionReturnType} from "../types/call_transaction_types";
import {endCallTransactionCallerCommon} from "./end_call_transaction_caller_common";

export const endCallTransactionCallerInitiated = async (
    {terminateRequest}: {terminateRequest: ClientCallTerminateRequest}):
    Promise<EndCallTransactionReturnType> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    if (terminateRequest.callTransactionId == null || terminateRequest.uid == null) {
      const errorMessage = `Invalid ClientCallTerminateRequest, either ids are null.
      CallTransactionId: ${terminateRequest.callTransactionId} Uid: ${terminateRequest.uid}`;
      return failure(errorMessage);
    }
    const [callTransactionLookupErrorMessage, callTransaction] = await getCallTransaction(
        terminateRequest.callTransactionId, transaction);
    if (callTransactionLookupErrorMessage !== "" || callTransaction === undefined) {
      return failure(callTransactionLookupErrorMessage);
    }

    if (terminateRequest.uid !== callTransaction.callerUid) {
      const errorMessage = `Uid: ${terminateRequest.uid} cannot terminate call: ${callTransaction.callerUid} 
      because they are not the caller`;
      return failure(errorMessage);
    }

    if (callTransaction.callHasEnded || callTransaction.callEndTimeUtsMs !== 0) {
      const errorMessage = `Uid: ${terminateRequest.uid} cannot terminate call: ${callTransaction.callerUid} 
      because is already terminate`;
      return failure(errorMessage);
    }

    return endCallTransactionCallerCommon({callTransaction: callTransaction,
      transaction: transaction});
  });
};


function failure(errorMessage: string): EndCallTransactionReturnType {
  console.error(`Error in EndCallTransactionCallerInitiated: ${errorMessage}`);
  return errorMessage;
}
