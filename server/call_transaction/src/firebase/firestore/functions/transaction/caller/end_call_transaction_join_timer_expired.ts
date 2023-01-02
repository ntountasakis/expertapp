import * as admin from "firebase-admin";
import {getCallTransactionDocumentRef} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";

export default async function endCallTransactionJoinTimerExpired({transactionId}: {transactionId: string}): Promise<void> {
  return await admin.firestore().runTransaction(async (transaction) => {
    transaction.update(getCallTransactionDocumentRef({transactionId: transactionId}), {
      "callHasExpired": true,
    });
  });
}
