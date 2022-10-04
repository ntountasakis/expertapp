import {endCallTransactionCalled} from "../called/end_call_transaction_called";

export const endCallTransactionClientDisconnect = async (
    {transactionId}: {transactionId: string}): Promise<void> => {
  console.log(`Running endCallTransactionClientDisconnect for transactionId: ${transactionId}`);
  await endCallTransactionCalled({transactionId: transactionId});
};
