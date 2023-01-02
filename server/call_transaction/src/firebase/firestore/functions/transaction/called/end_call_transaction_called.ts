import * as admin from "firebase-admin";
import {getCallTransactionDocument} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {getUtcMsSinceEpoch} from "../../../../../../../shared/src/general/utils";
import {markCallEnd} from "../../util/call_transaction_complete";

export const endCallTransactionCalled = async ({transactionId}: {transactionId: string}): Promise<void> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument({transaction: transaction, transactionId: transactionId});
    if (!callTransaction.callHasEnded) {
      const callEndTimeUtcMs = getUtcMsSinceEpoch();
      markCallEnd(callTransaction.callTransactionId, callEndTimeUtcMs, transaction);
      callTransaction.callEndTimeUtsMs = callEndTimeUtcMs;
    }
  });
};
