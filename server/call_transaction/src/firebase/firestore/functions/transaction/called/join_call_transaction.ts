import * as admin from "firebase-admin";
import {getCallTransactionDocument, getCallTransactionDocumentRef} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {ClientCallJoinRequest} from "../../../../../protos/call_transaction_package/ClientCallJoinRequest";

export const joinCallTransaction = async ({request}: {request: ClientCallJoinRequest}):
Promise<void> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    if (request.callTransactionId == null || request.joinerUid == null) {
      throw new Error("ClientCallJoinRequest has null fields");
    }
    const callTransaction = await getCallTransactionDocument({transactionId: request.callTransactionId});
    let errorMessage = `Call Transaction ID: ${request.callTransactionId} `;

    if (callTransaction.calledHasJoined || callTransaction.calledJoinTimeUtcMs !== 0) {
      errorMessage += `has invalid fields. CalledHasJoined: ${callTransaction.calledHasJoined}
       CalledJoinTimeUtcMs: ${callTransaction.callRequestTimeUtcMs}`;
      throw new Error(errorMessage);
    }

    callTransaction.calledHasJoined = true;
    callTransaction.calledJoinTimeUtcMs = Date.now();
    getCallTransactionDocumentRef({transactionId: request.callTransactionId}).update({
      "calledHasJoined": true,
      "calledJoinTimeUtcMs": Date.now(),
    });

    console.log(`CallTransaction joined. TransactionId: ${callTransaction.callTransactionId} 
        JoinedId: ${callTransaction.calledUid} `);
  });
};
