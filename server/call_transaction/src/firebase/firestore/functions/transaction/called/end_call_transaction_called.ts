import * as admin from "firebase-admin";
import createStripePaymentTransfer from "../../../../../stripe/payment_transfer_creator";
import {calculateCostOfCallInCents} from "../../util/call_cost_calculator";
import {getCallTransaction} from "../../util/model_fetchers";

// todo: make sure this is idempotent

export const endCallTransactionCalled = async ({transactionId}: {transactionId: string}): Promise<string> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    const [callTransactionLookupErrorMessage, callTransaction] = await getCallTransaction(transactionId, transaction);
    if (callTransactionLookupErrorMessage !== "" || callTransaction === undefined) {
      return failure(callTransactionLookupErrorMessage);
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
      return failure("Cannot transfer funds to expert. Empty caller Transfer");
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


function failure(errorMessage: string): string {
  console.error(`Error in EndCallTransaction: ${errorMessage}`);
  return errorMessage;
}
