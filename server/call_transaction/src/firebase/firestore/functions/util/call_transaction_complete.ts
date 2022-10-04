import {getCallTransactionDocumentRef} from "../../../../../../shared/firebase/firestore/document_fetchers/fetchers";

export async function markCallEnd(transactionId: string,
    callEndTimeUtcMs: number, transaction: FirebaseFirestore.Transaction): Promise<void> {
  console.log(`Marking callHasEnded in with ID: ${transactionId}`);
  transaction.update(getCallTransactionDocumentRef({transactionId: transactionId}), {
    "callHasEnded": true,
    "callEndTimeUtsMs": callEndTimeUtcMs,
  });
}
