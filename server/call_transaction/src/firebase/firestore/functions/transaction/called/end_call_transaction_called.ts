import * as admin from "firebase-admin";
import {getCallTransactionDocument} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/firebase/firestore/models/call_transaction";
import {markCallEnd} from "../../util/call_transaction_complete";

export const endCallTransactionCalled = async ({transactionId}: {transactionId: string}): Promise<CallTransaction> => {
  await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});
    if (!callTransaction.callHasEnded) {
      const nowMs = Date.now();
      markCallEnd(callTransaction.callTransactionId, nowMs, transaction);
      callTransaction.callEndTimeUtsMs = nowMs;
    }
  });
  return await admin.firestore().runTransaction(async (transaction) => {
    return await getCallTransactionDocument({transaction: transaction, transactionId: transactionId});
  });
};
