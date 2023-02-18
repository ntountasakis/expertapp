import * as admin from "firebase-admin";
import {getUtcMsSinceEpoch, isStringDefined} from "../../../../../../../shared/src/general/utils";
import {getCallTransactionDocument, getCallTransactionDocumentRef, getPrivateUserDocument, getPublicExpertInfo, getPublicExpertInfoDocumentRef} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {PrivateUserInfo} from "../../../../../../../shared/src/firebase/firestore/models/private_user_info";
import {ClientCallJoinRequest} from "../../../../../protos/call_transaction_package/ClientCallJoinRequest";
import {PublicExpertInfo} from "../../../../../../../shared/src/firebase/firestore/models/public_expert_info";

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
    const publicExpertInfo: PublicExpertInfo = await getPublicExpertInfo({transaction: transaction, uid: callTransaction.calledUid});

    if (!isStringDefined(userInfo.stripeConnectedId)) {
      console.error(`Uid ${callTransaction.calledUid} has no connected stripe account. Cannot join call`);
      return [false, callTransaction];
    }
    if (callTransaction.callerFinishedTransaction) {
      console.error(`CallTransaction ${transactionId} has already ended. Cannot join call`);
      return [false, callTransaction];
    }
    if (publicExpertInfo.inCall) {
      console.error(`Uid ${callTransaction.calledUid} is in another call. Cannot join another`);
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
    transaction.update(getPublicExpertInfoDocumentRef({uid: callTransaction.calledUid}), {
      "inCall": true,
    });
    return [true, callTransaction];
  });
};
