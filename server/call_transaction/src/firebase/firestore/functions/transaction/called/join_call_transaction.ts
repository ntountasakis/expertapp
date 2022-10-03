import * as admin from "firebase-admin";
import { getCallTransactionDocumentRef } from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import { CallTransaction } from "../../../../../../../shared/firebase/firestore/models/call_transaction";
import {ClientCallJoinRequest} from "../../../../../protos/call_transaction_package/ClientCallJoinRequest";

type CallTransactionJoinReturnType = [valid: boolean, errorMessage: string];

export const joinCallTransaction = async ({request}: {request: ClientCallJoinRequest}):
Promise<CallTransactionJoinReturnType> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    if (request.callTransactionId == null || request.joinerUid == null) {
      return callTransactionFailure("ClientCallJoinRequest has null fields");
    }
    const callTransactionRef = getCallTransactionDocumentRef({transactionId: request.callTransactionId});
    const callTransactionDoc = await callTransactionRef.get();

    let errorMessage = `Call Transaction ID: ${request.callTransactionId} `;
    if (!callTransactionDoc.exists) {
      return callTransactionFailure(errorMessage += "does not exist");
    }
    const callTransaction = callTransactionDoc.data() as CallTransaction;

    if (callTransaction.calledHasJoined || callTransaction.calledJoinTimeUtcMs !== 0) {
      errorMessage += `has invalid fields. CalledHasJoined: ${callTransaction.calledHasJoined}
       CalledJoinTimeUtcMs: ${callTransaction.callRequestTimeUtcMs}`;
      return callTransactionFailure(errorMessage);
    }

    callTransaction.calledHasJoined = true;
    callTransaction.calledJoinTimeUtcMs = Date.now();
    callTransactionRef.update({
      "calledHasJoined": true,
      "calledJoinTimeUtcMs": Date.now()
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
