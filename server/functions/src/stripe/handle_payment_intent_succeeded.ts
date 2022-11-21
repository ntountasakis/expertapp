import * as admin from "firebase-admin";
import {resolvePaymentStatusAndUpdateBalance} from "../../../shared/src/firebase/firestore/functions/resolve_payment_status_and_update_balance";

export async function handlePaymentIntentSucceeded(payload: any): Promise<void> {
  const amount: number = payload.amount;
  const amountReceived: number = payload.amount_received;
  //   const livemode: boolean = payload.livemode;
  const status = payload.status;
  const paymentStatusId: string = payload.metadata.payment_status_id;
  const uid: string = payload.metadata.uid;

  if (paymentStatusId == undefined) {
    console.error("Cannot handle PaymentIntent Success. PaymentId undefined");
    return;
  }
  if (uid == undefined) {
    console.error("Cannot handle PaymentIntent Success. Uid undefined");
    return;
  }
  if (amount != amountReceived) {
    console.error(`PaymentStatus ID: ${paymentStatusId} Not paid in full. 
        Expected: ${amount} Received: ${amountReceived}`);
    return;
  }

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      await resolvePaymentStatusAndUpdateBalance({transaction: transaction, paymentStatusId: paymentStatusId,
        amountReceived: amountReceived, status: status, uid: uid});
    });
  } catch (error) {
    console.error(`Error in HandlePaymentIntentSuceeded: ${error}`);
  }
}
