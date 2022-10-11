import * as admin from "firebase-admin";
import {getCallTransactionDocument, getCallTransactionDocumentRef} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/firebase/firestore/models/call_transaction";
import {ClientCallJoinRequest} from "../../../../../protos/call_transaction_package/ClientCallJoinRequest";

export const joinCallTransaction = async ({request}: {request: ClientCallJoinRequest}):
Promise<CallTransaction> => {
  if (request.callTransactionId == null) {
    throw new Error("ClientCallJoinRequest has null fields");
  }
  const transactionId = request.callTransactionId;
  await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});
    let errorMessage = `Call Transaction ID: ${request.callTransactionId} `;

    if (callTransaction.calledHasJoined || callTransaction.calledJoinTimeUtcMs !== 0) {
      errorMessage += `has invalid fields. CalledHasJoined: ${callTransaction.calledHasJoined}
       CalledJoinTimeUtcMs: ${callTransaction.callRequestTimeUtcMs}`;
      throw new Error(errorMessage);
    }

    callTransaction.calledHasJoined = true;
    callTransaction.calledJoinTimeUtcMs = Date.now();
    getCallTransactionDocumentRef({transactionId: transactionId}).update({
      "calledHasJoined": true,
      "calledJoinTimeUtcMs": Date.now(),
    });

    console.log(`CallTransaction joined. TransactionId: ${callTransaction.callTransactionId} 
        JoinedId: ${callTransaction.calledUid} `);
  });
  return await admin.firestore().runTransaction(async (transaction) => {
    return getCallTransactionDocument({transaction: transaction, transactionId: transactionId});
  });
};
