import { getCallTransactionDocumentRef } from "../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import { CallTransaction } from "../../../../../../shared/firebase/firestore/models/call_transaction";

export function markCallEndIfNotAlready( callTransactionModel: CallTransaction,
    callEndTimeUtcMs: number,
    transaction: FirebaseFirestore.Transaction): void {
  if (!callTransactionModel.callHasEnded) {
    console.log(`Marking callHasEnded in with ID: ${callTransactionModel.callTransactionId}`);
    transaction.update(getCallTransactionDocumentRef({transactionId: callTransactionModel.callTransactionId}), {
      "callHasEnded": true,
      "callEndTimeUtsMs": callEndTimeUtcMs,
    });
  }
}
