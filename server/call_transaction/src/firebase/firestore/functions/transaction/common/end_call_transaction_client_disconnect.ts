import * as admin from "firebase-admin";
import {markCallEndIfNotAlready} from "../../util/call_transaction_complete";
import {getCallTransaction} from "../../util/model_fetchers";

export const endCallTransactionClientDisconnect = async (
    {transactionId}: {transactionId: string}): Promise<void> => {
  console.log(`Running endCallTransactionClientDisconnect for transactionId: ${transactionId}`);

  const errorMsgPrefix = "Error in endCallTransactionClientDisconnect. ";
  await admin.firestore().runTransaction(async (transaction) => {
    const [callTransactionLookupErrorMessage, callTransaction] = await getCallTransaction(
        transactionId, transaction);
    if (callTransactionLookupErrorMessage !== "" || callTransaction === undefined) {
      console.error(errorMsgPrefix + `Cannot find CallTransaction with ID: ${transactionId}`);
      return;
    }
    markCallEndIfNotAlready(callTransaction, Date.now(), transaction);
  });
};
