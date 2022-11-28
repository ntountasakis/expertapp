import * as admin from "firebase-admin";
import {getCallTransactionDocument, getPrivateUserDocument} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {PrivateUserInfo} from "../../../../../../../shared/src/firebase/firestore/models/private_user_info";
import {markCallEnd} from "../../util/call_transaction_complete";

export const endCallTransactionCalled = async ({transactionId}: {transactionId: string}): Promise<[CallTransaction, PrivateUserInfo]> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});
    const userInfo = await getPrivateUserDocument({transaction: transaction, uid: callTransaction.calledUid});
    if (!callTransaction.callHasEnded) {
      const nowMs = Date.now();
      markCallEnd(callTransaction.callTransactionId, nowMs, transaction);
      callTransaction.callEndTimeUtsMs = nowMs;
    }
    return [callTransaction, userInfo];
  });
};
