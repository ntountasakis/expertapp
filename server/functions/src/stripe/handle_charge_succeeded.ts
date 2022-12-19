import * as admin from "firebase-admin";
import {updatePaymentStatusAmountCharged} from "../../../shared/src/firebase/firestore/functions/update_payment_status_charged";
import {PaymentStatusStates} from "../../../shared/src/firebase/firestore/models/payment_status";

// todo audit me was tired

export async function handleChargeSuceeded(payload: any): Promise<void> {
  const amount: number = payload.amount;
  const amountCaptured: number = payload.amount_captured;
  //   const livemode: boolean = payload.livemode;
  const status = payload.status;
  const paymentStatusId: string = payload.metadata.payment_status_id;
  const uid: string = payload.metadata.uid;

  if (paymentStatusId == undefined) {
    console.error("Cannot handle ChargeSuceeded. PaymentId undefined");
    return;
  }
  if (uid == undefined) {
    console.error("Cannot handle ChargeSuceeded. Uid undefined");
    return;
  }
  if (status != "succeeded") { // todo stripe enum
    console.error(`PaymentStatus ID: ${paymentStatusId} status unexpected. 
        Expected: succeeded Received: ${status}`);
    return;
  }

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      await updatePaymentStatusAmountCharged({transaction: transaction, paymentStatusId: paymentStatusId,
        amountCapturedCents: amountCaptured, status: PaymentStatusStates.PRE_AUTH_CONFIRMED,
        uid: uid});
    });
  } catch (error) {
    console.error(`Error in HandleChargeSuceeded: ${error}`);
  }
}
