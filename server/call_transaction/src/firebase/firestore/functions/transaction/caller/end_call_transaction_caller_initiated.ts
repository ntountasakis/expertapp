import * as admin from "firebase-admin";
import {getCallTransactionDocument} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
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
      throw new Error(errorMessage);
    }
    const callTransaction: CallTransaction =
    await getCallTransactionDocument({transactionId: terminateRequest.callTransactionId});

    if (terminateRequest.uid !== callTransaction.callerUid) {
      const errorMessage = `Uid: ${terminateRequest.uid} cannot terminate call: ${callTransaction.callerUid} 
      because they are not the caller`;
      throw new Error(errorMessage);
    }

    if (callTransaction.callHasEnded || callTransaction.callEndTimeUtsMs !== 0) {
      const errorMessage = `Uid: ${terminateRequest.uid} cannot terminate call: ${callTransaction.callerUid} 
      because is already terminate`;
      throw new Error(errorMessage);
    }

    return endCallTransactionCallerCommon({callTransaction: callTransaction,
      transaction: transaction});
  });
};
