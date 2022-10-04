import * as admin from "firebase-admin";
import {getCallTransactionDocumentRef} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/firebase/firestore/models/call_transaction";
import {ClientCallTerminateRequest} from "../../../../../protos/call_transaction_package/ClientCallTerminateRequest";
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
    const callTransactionDoc = await getCallTransactionDocumentRef({
      transactionId: terminateRequest.callTransactionId}).get();
    if (!callTransactionDoc.exists) {
      return failure(`No call transaction for ${terminateRequest.callTransactionId}`);
    }
    const callTransaction = callTransactionDoc.data() as CallTransaction;

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
