import {v4 as uuidv4} from "uuid";
import * as admin from "firebase-admin";
import {getCallTransactionDocument, getCallTransactionDocumentRef} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {calculateCostOfCallInCents} from "../../util/call_cost_calculator";
import {markCallEnd} from "../../util/call_transaction_complete";
import {createPaymentStatus} from "../../../../../../../shared/src/firebase/firestore/functions/create_payment_status";

export const endCallTransactionCaller = async ({transactionId} : {transactionId: string}): Promise<CallTransaction> => {
  const paymentStatusId = uuidv4();
  let endTimeUtcMs = Date.now();
  await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});
    if (!callTransaction.callHasEnded) {
      markCallEnd(callTransaction.callTransactionId, endTimeUtcMs, transaction);
    } else {
      endTimeUtcMs = callTransaction.callEndTimeUtsMs;
    }
    const costOfCallInCents = calculateCostOfCallInCents({
      beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs,
      endTimeUtcMs: endTimeUtcMs,
      centsPerMinute: callTransaction.expertRateCentsPerMinute,
    });
    createPaymentStatus({transaction: transaction, uid: callTransaction.callerUid,
      paymentStatusId: paymentStatusId, transferGroup: callTransaction.callerTransferGroup,
      costInCents: costOfCallInCents});
    transaction.update(getCallTransactionDocumentRef({transactionId: transactionId}), {
      "callerCallTerminatePaymentStatusId": paymentStatusId,
      "callerFinalCostCallTerminate": costOfCallInCents,
    });
  });

  return await admin.firestore().runTransaction(async (transaction) => {
    return await getCallTransactionDocument({transaction: transaction, transactionId: transactionId});
  });
};
