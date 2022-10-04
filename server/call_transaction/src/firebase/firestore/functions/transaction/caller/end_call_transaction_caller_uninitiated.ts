import * as admin from "firebase-admin";
import {getCallTransactionDocumentRef} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/firebase/firestore/models/call_transaction";
import {EndCallTransactionReturnType} from "../types/call_transaction_types";
import {endCallTransactionCallerCommon} from "./end_call_transaction_caller_common";

export const endCallTransactionCallerUninitiated = async ({transactionId}: {transactionId: string}):
Promise<EndCallTransactionReturnType> => {
  return admin.firestore().runTransaction(async (transaction) => {
    const callTransactionDoc = await getCallTransactionDocumentRef({transactionId: transactionId}).get();
    if (!callTransactionDoc.exists) {
      return failure(`No call transaction for ${transactionId}`);
    }
    return endCallTransactionCallerCommon({callTransaction: callTransactionDoc.data() as CallTransaction,
      transaction: transaction});
  });
};

function failure(errorMessage: string): EndCallTransactionReturnType {
  console.error(`Error in EndCallTransactionCallerUninitiated: ${errorMessage}`);
  return errorMessage;
}
