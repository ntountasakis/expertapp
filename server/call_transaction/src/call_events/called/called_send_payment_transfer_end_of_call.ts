import {CallTransaction} from "../../../../shared/src/firebase/firestore/models/call_transaction";
import {PrivateUserInfo} from "../../../../shared/src/firebase/firestore/models/private_user_info";
import createStripePaymentTransfer from "../../../../shared/src/stripe/payment_transfer_creator";
import {calculateCostOfCallInCents} from "../../firebase/firestore/functions/util/call_cost_calculator";

export async function calledSendPaymentTransferEndOfCall(
    {callTransaction, userInfo}: {callTransaction: CallTransaction, userInfo: PrivateUserInfo}): Promise<void> {
  const costOfCallInCents = calculateCostOfCallInCents({
    beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs,
    endTimeUtcMs: callTransaction.callEndTimeUtsMs,
    centsPerMinute: callTransaction.expertRateCentsPerMinute,
  });
  const amountToTransferInCents = callTransaction.expertRateCentsCallStart + costOfCallInCents;

  console.log(`Ending callTransaction for called: BeginTime: ${callTransaction.calledJoinTimeUtcMs} 
    EndTime: ${callTransaction.callEndTimeUtsMs} CentsPerMinute: ${callTransaction.expertRateCentsPerMinute} 
    CentsStartCall: ${callTransaction.expertRateCentsCallStart} TotalToTransfer: ${amountToTransferInCents}`);

  const transferId: string = await createStripePaymentTransfer({connectedAccountId: userInfo.stripeConnectedId,
    amountToTransferInCents: amountToTransferInCents, transferGroup: callTransaction.callerTransferGroup});

  console.log(`Successfully issued transfer with id: ${transferId} to account: ${userInfo.stripeConnectedId}`);
}
