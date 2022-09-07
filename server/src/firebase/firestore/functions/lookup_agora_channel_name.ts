import * as admin from "firebase-admin";
import {CallTransaction} from "../models/call_transaction";

export async function lookupAgoraChannelName({callTransactionId}: {callTransactionId: string}):
    Promise<[success: boolean, errorMessage: string, agoraChannelName: string]> {
  const callTransactions = admin.firestore().collection("call_transactions");
  const transactionDocument = await callTransactions.doc(callTransactionId).get();
  if (!transactionDocument.exists) {
    return [false, `Cannot find agora channel name for callTransactionId: ${callTransactionId}`, ""];
  }
  const transactionModel = transactionDocument.data() as CallTransaction;
  return [true, "", transactionModel.agoraChannelName];
}
