import * as admin from "firebase-admin";
import {getCallTransactionDocument, getCallTransactionDocumentRef} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {ClientCallJoinRequest} from "../../../../../protos/call_transaction_package/ClientCallJoinRequest";

type CallTransactionJoinReturnType = [valid: boolean, errorMessage: string];

export const joinCallTransaction = async ({request}: {request: ClientCallJoinRequest}):
Promise<CallTransactionJoinReturnType> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    if (request.callTransactionId == null || request.joinerUid == null) {
      return callTransactionFailure("ClientCallJoinRequest has null fields");
    }
    const callTransaction = await getCallTransactionDocument({transactionId: request.callTransactionId});
    let errorMessage = `Call Transaction ID: ${request.callTransactionId} `;

    if (callTransaction.calledHasJoined || callTransaction.calledJoinTimeUtcMs !== 0) {
      errorMessage += `has invalid fields. CalledHasJoined: ${callTransaction.calledHasJoined}
       CalledJoinTimeUtcMs: ${callTransaction.callRequestTimeUtcMs}`;
      return callTransactionFailure(errorMessage);
    }

    callTransaction.calledHasJoined = true;
    callTransaction.calledJoinTimeUtcMs = Date.now();
    getCallTransactionDocumentRef({transactionId: request.callTransactionId}).update({
      "calledHasJoined": true,
      "calledJoinTimeUtcMs": Date.now(),
    });

    console.log(`CallTransaction joined. TransactionId: ${callTransaction.callTransactionId} 
        JoinedId: ${callTransaction.calledUid} `);
    return [true, ""];
  });
};

function callTransactionFailure(errorMessage: string): CallTransactionJoinReturnType {
  console.error(`Error in CallTransactionJoin: ${errorMessage}`);
  return [false, errorMessage];
}
