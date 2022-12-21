import {CallTransaction} from "../../../../shared/src/firebase/firestore/models/call_transaction";
import {PrivateUserInfo} from "../../../../shared/src/firebase/firestore/models/private_user_info";
import createStripePaymentTransfer from "../../../../shared/src/stripe/payment_transfer_creator";
import {calculateCostOfCallInCents} from "../../firebase/firestore/functions/util/call_cost_calculator";

// todo: we should put this in the payment status so we aren't recalculating

export async function calledSendPaymentTransferEndOfCall(
    {callTransaction, userInfo}: {callTransaction: CallTransaction, userInfo: PrivateUserInfo}): Promise<void> {
  const costOfCallInCents = calculateCostOfCallInCents({
    beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs,
    endTimeUtcMs: callTransaction.callEndTimeUtsMs,
    centsPerMinute: callTransaction.expertRateCentsPerMinute,
    centsStartCall: callTransaction.expertRateCentsCallStart,
  });
  console.log(`Ending callTransaction for called: BeginTime: ${callTransaction.calledJoinTimeUtcMs} 
    EndTime: ${callTransaction.callEndTimeUtsMs} CentsPerMinute: ${callTransaction.expertRateCentsPerMinute} 
    CentsStartCall: ${callTransaction.expertRateCentsCallStart} TotalToTransfer: ${costOfCallInCents}`);

  const transferId: string = await createStripePaymentTransfer({connectedAccountId: userInfo.stripeConnectedId,
    amountToTransferInCents: costOfCallInCents, transferGroup: callTransaction.callerTransferGroup});

  console.log(`Successfully issued transfer with id: ${transferId} to account: ${userInfo.stripeConnectedId}`);
}
