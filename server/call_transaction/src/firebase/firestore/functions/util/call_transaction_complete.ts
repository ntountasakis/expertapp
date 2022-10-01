import {CallTransaction} from "../../models/call_transaction";
import {getCallTransactionRef} from "./model_fetchers";

export function markCallEndIfNotAlready( callTransactionModel: CallTransaction,
    callEndTimeUtcMs: number,
    transaction: FirebaseFirestore.Transaction): void {
  if (!callTransactionModel.callHasEnded) {
    console.log(`Marking callHasEnded in with ID: ${callTransactionModel.callTransactionId}`);
    transaction.update(getCallTransactionRef(callTransactionModel.callTransactionId), {
      "callHasEnded": true,
      "callEndTimeUtsMs": callEndTimeUtcMs,
    });
  }
}
