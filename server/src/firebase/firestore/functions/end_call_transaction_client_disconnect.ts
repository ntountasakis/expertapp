import * as admin from "firebase-admin";
import {CallTransaction} from "../models/call_transaction";
import {getCallTransaction, getCallTransactionRef} from "./util/model_fetchers";

export const endCallTransactionClientDisconnect = async (
    {transactionId}: {transactionId: string}): Promise<void> => {
  console.log(`Running endCallTransactionClientDisconnect for transactionId: ${transactionId}`);

  const errorMsgPrefix = "Error in endCallTransactionClientDisconnect. ";
  admin.firestore().runTransaction(async (transaction) => {
    const [callTransactionLookupErrorMessage, callTransaction] = await getCallTransaction(
        transactionId, transaction);
    if (callTransactionLookupErrorMessage !== "" || callTransaction === undefined) {
      console.error(errorMsgPrefix + `Cannot find CallTransaction with ID: ${transactionId}`);
      return;
    }
    markCallEndIfNotAlready(transactionId, callTransaction, transaction);
  });
};

function markCallEndIfNotAlready(callTransactionId: string,
    callTransactionModel: CallTransaction, transaction: FirebaseFirestore.Transaction) {
  if (!callTransactionModel.callHasEnded) {
    console.log(`Marking callHasEnded in endCallTransactionClientDisconnect with ID: ${callTransactionId}`);
    transaction.update(getCallTransactionRef(callTransactionId), {
      "callHasEnded": true,
      "callEndTimeUtsMs": Date.now(),
    });
  }
}
