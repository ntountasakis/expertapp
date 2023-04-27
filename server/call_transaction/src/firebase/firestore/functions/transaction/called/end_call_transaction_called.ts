import * as admin from "firebase-admin";
import {BaseCallState} from "../../../../../call_state/common/base_call_state";
import {ServerCallSummary} from "../../../../../protos/call_transaction_package/ServerCallSummary";
import {markCallEndGenerateCallSummary} from "../common/mark_call_end_generate_call_summary";
import {CallTransaction} from "../../../../../../../functions/src/shared/src/firebase/firestore/models/call_transaction";
import {getCallTransactionDocument} from "../../../../../../../functions/src/shared/src/firebase/firestore/document_fetchers/fetchers";
import {getUtcMsSinceEpoch} from "../../../../../../../functions/src/shared/src/general/utils";

export const endCallTransactionCalled = async ({transactionId, callState}: {transactionId: string, callState: BaseCallState}): Promise<ServerCallSummary> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument({transaction: transaction, transactionId: transactionId});
    const callSummary: ServerCallSummary = await markCallEndGenerateCallSummary(
        {transaction: transaction, callTransaction: callTransaction, endCallTimeUtcMs: getUtcMsSinceEpoch(), callState: callState});
    return callSummary;
  });
};
