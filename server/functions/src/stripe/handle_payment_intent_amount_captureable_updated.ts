import * as admin from "firebase-admin";
import {updatePaymentStatusAmountAuthorized} from "../../../shared/src/firebase/firestore/functions/update_payment_status_authorized";
import {PaymentStatusStates} from "../../../shared/src/firebase/firestore/models/payment_status";

export async function handlePaymentAmountCaptureableUpdated(payload: any): Promise<void> {
  const amount: number = payload.amount;
  const amountCapturable: number = payload.amount_capturable;
  //   const livemode: boolean = payload.livemode;
  const status = payload.status;
  const paymentStatusId: string = payload.metadata.payment_status_id;
  const uid: string = payload.metadata.uid;

  if (paymentStatusId == undefined) {
    console.error("Cannot handle PaymentIntentAmountCapturableUpdated. PaymentId undefined");
    return;
  }
  if (uid == undefined) {
    console.error("Cannot handle PaymentIntentAmountCapturableUpdated. Uid undefined");
    return;
  }
  if (amount != amountCapturable) {
    console.error(`PaymentStatus ID: ${paymentStatusId} Not fully capturable. 
        Expected: ${amount} Received: ${amountCapturable}`);
    return;
  }
  if (status != "requires_capture") { // todo use Stripe enum
    console.error(`PaymentStatus ID: ${paymentStatusId} status unexpected. 
        Expected: requires_capture Received: ${status}`);
    return;
  }

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      await updatePaymentStatusAmountAuthorized({transaction: transaction, paymentStatusId: paymentStatusId,
        amountReceived: amountCapturable, status: PaymentStatusStates.PRE_AUTH_CONFIRMED});
    });
  } catch (error) {
    console.error(`Error in PaymentIntentAmountCapturableUpdated: ${error}`);
  }
}
