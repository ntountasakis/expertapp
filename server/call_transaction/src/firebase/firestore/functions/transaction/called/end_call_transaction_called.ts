import * as admin from "firebase-admin";
import {getCallTransactionDocument} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/firebase/firestore/models/call_transaction";
import createStripePaymentTransfer from "../../../../../stripe/payment_transfer_creator";
import {calculateCostOfCallInCents} from "../../util/call_cost_calculator";
import {markCallEnd} from "../../util/call_transaction_complete";

export const endCallTransactionCalled = async ({transactionId}: {transactionId: string}): Promise<string> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument({transactionId: transactionId});
    if (!callTransaction.callHasEnded) {
      const nowMs = Date.now();
      markCallEnd(callTransaction.callTransactionId, nowMs, transaction);
      callTransaction.callEndTimeUtsMs = nowMs;
    }
    const costOfCallInCents = calculateCostOfCallInCents({
      beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs,
      endTimeUtcMs: callTransaction.callEndTimeUtsMs,
      centsPerMinute: callTransaction.expertRateCentsPerMinute,
    });
    const amountToTransferInCents = callTransaction.expertRateCentsCallStart + costOfCallInCents;

    console.log(`Ending callTransaction for called: BeginTime: ${callTransaction.calledJoinTimeUtcMs} 
    EndTime: ${callTransaction.callEndTimeUtsMs} CentsPerMinute: ${callTransaction.expertRateCentsPerMinute} 
    CentsStartCall: ${callTransaction.expertRateCentsCallStart} TotalToTransfer: ${amountToTransferInCents}`);

    if (callTransaction.callerTransferGroup == "") {
      throw new Error("Cannot transfer funds to expert. Empty caller Transfer");
    }

    // todo:
    const stripeConnectedAccountId = "acct_1LmpLYPKLydnyIBv";

    const transferId: string = await createStripePaymentTransfer({connectedAccountId: stripeConnectedAccountId,
      amountToTransferInCents: amountToTransferInCents,
      transferGroup: callTransaction.callerTransferGroup});

    console.log(`Successfully issued transfer with id: ${transferId} to account: ${stripeConnectedAccountId}`);

    return "";
  });
};
