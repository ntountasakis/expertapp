import * as admin from "firebase-admin";
import {getCallTransaction} from "../../util/model_fetchers";
import {EndCallTransactionReturnType} from "../types/call_transaction_types";
import {endCallTransactionCallerCommon} from "./end_call_transaction_caller_common";

export const endCallTransactionCallerUninitiated = async ({transactionId}: {transactionId: string}):
Promise<EndCallTransactionReturnType> => {
  return admin.firestore().runTransaction(async (transaction) => {
    const [callTransactionLookupErrorMessage, callTransaction] = await getCallTransaction(
        transactionId, transaction);
    if (callTransactionLookupErrorMessage !== "" || callTransaction === undefined) {
      return failure(callTransactionLookupErrorMessage);
    }
    return endCallTransactionCallerCommon({callTransaction: callTransaction,
      transaction: transaction});
  });
};

function failure(errorMessage: string): EndCallTransactionReturnType {
  console.error(`Error in EndCallTransaction: ${errorMessage}`);
  return errorMessage;
}
