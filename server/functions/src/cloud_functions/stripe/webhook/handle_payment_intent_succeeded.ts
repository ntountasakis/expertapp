import * as admin from "firebase-admin";
import {updatePaymentStatus} from "../../../firebase/firestore/functions/update_payment_status";

export async function handlePaymentIntentSucceeded(payload: any): Promise<void> {
  const amount: number = payload.amount;
  const amountReceived: number = payload.amount_received;
  //   const livemode: boolean = payload.livemode;
  const status = payload.status;
  const paymentStatusId: string = payload.metadata.payment_status_id;

  if (paymentStatusId == undefined) {
    console.error("Cannot handle PaymentIntent Success. PaymentId undefined");
    return;
  }
  if (amount != amountReceived) {
    console.error(`PaymentStatus ID: ${paymentStatusId} Not paid in full. 
        Expected: ${amount} Received: ${amountReceived}`);
    return;
  }

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      await updatePaymentStatus({transaction: transaction, paymentStatusId: paymentStatusId,
        amountReceived: amountReceived, status: status});
    });
  } catch (error) {
    console.error(`Error in HandlePaymentIntentSuceeded: ${error}`);
  }
}
