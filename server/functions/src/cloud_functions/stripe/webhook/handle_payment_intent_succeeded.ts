import * as admin from "firebase-admin";
import {updatePaymentStatus} from "../../../firebase/firestore/functions/update_payment_status";

export async function handlePaymentIntentSucceeded(payload: any): Promise<void> {
  const id: string = payload.id;
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

  await admin.firestore().runTransaction(async (transaction) => {
    updatePaymentStatus({transaction: transaction, paymentStatusId: paymentStatusId, amountReceived: amountReceived,
      status: status})
        .then(() => {
          console.log(`PaymentIntent Success! ID: ${id} Amount: ${amount}
          AmountReceived: ${amountReceived} Status: ${status} PaymentId: ${paymentStatusId}`);
        })
        .catch((reason) => {
          console.error(reason);
        });
  });
}
