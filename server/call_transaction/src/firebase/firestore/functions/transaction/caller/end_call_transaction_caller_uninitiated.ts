import * as admin from "firebase-admin";
import {getCallTransactionDocument} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/firebase/firestore/models/call_transaction";
import {EndCallTransactionReturnType} from "../types/call_transaction_types";
import {endCallTransactionCallerCommon} from "./end_call_transaction_caller_common";

export const endCallTransactionCallerUninitiated = async ({transactionId}: {transactionId: string}):
Promise<EndCallTransactionReturnType> => {
  return admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument({transactionId: transactionId});
    return endCallTransactionCallerCommon({callTransaction: callTransaction,
      transaction: transaction});
  });
};
