import { getCallTransactionDocumentRef } from "../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import { CallTransaction } from "../../../../../../shared/firebase/firestore/models/call_transaction";

export async function lookupAgoraChannelName({callTransactionId}: {callTransactionId: string}):
    Promise<[success: boolean, errorMessage: string, agoraChannelName: string]> {
  const transactionDocument = await getCallTransactionDocumentRef({transactionId: callTransactionId}).get()
  if (!transactionDocument.exists) {
    return [false, `Cannot find agora channel name for callTransactionId: ${callTransactionId}`, ""];
  }
  const transactionModel = transactionDocument.data() as CallTransaction;
  return [true, "", transactionModel.agoraChannelName];
}
