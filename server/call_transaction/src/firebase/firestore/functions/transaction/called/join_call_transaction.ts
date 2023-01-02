import * as admin from "firebase-admin";
import {getUtcMsSinceEpoch, isStringDefined} from "../../../../../../../shared/src/general/utils";
import {getCallTransactionDocument, getCallTransactionDocumentRef, getPrivateUserDocument} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {PrivateUserInfo} from "../../../../../../../shared/src/firebase/firestore/models/private_user_info";
import {ClientCallJoinRequest} from "../../../../../protos/call_transaction_package/ClientCallJoinRequest";

export const joinCallTransaction = async ({request}: {request: ClientCallJoinRequest}):
Promise<[boolean, CallTransaction]> => {
  if (request.callTransactionId == null) {
    throw new Error("ClientCallJoinRequest has null fields");
  }
  const transactionId = request.callTransactionId;
  return await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});
    const userInfo: PrivateUserInfo = await getPrivateUserDocument({transaction: transaction, uid: callTransaction.calledUid});

    if (!isStringDefined(userInfo.stripeConnectedId)) {
      console.error(`Uid ${callTransaction.calledUid} has no connected stripe account. Cannot join call`);
      return [false, callTransaction];
    }
    if (callTransaction.callHasExpired) {
      console.error(`CallTransaction ${transactionId} has expired. Cannot join call`);
      return [false, callTransaction];
    }

    let errorMessage = `Call Transaction ID: ${request.callTransactionId} `;

    if (callTransaction.calledHasJoined || callTransaction.calledJoinTimeUtcMs !== 0) {
      errorMessage += `has invalid fields. CalledHasJoined: ${callTransaction.calledHasJoined}
       CalledJoinTimeUtcMs: ${callTransaction.callRequestTimeUtcMs}`;
      throw new Error(errorMessage);
    }

    callTransaction.calledHasJoined = true;
    callTransaction.calledJoinTimeUtcMs = getUtcMsSinceEpoch();
    transaction.update(getCallTransactionDocumentRef({transactionId: transactionId}), {
      "calledHasJoined": callTransaction.calledHasJoined,
      "calledJoinTimeUtcMs": callTransaction.calledJoinTimeUtcMs,
    });

    console.log(`CallTransaction joined. TransactionId: ${callTransaction.callTransactionId} 
        JoinedId: ${callTransaction.calledUid} `);

    return [true, callTransaction];
  });
};
