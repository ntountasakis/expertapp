import * as admin from "firebase-admin";
import {getPaymentStatusDocumentTransaction} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {updatePaymentStatus} from "../../../shared/src/firebase/firestore/functions/update_payment_status";
import {PaymentStatusStates} from "../../../shared/src/firebase/firestore/models/payment_status";

export async function handleChargeSuceeded(payload: any): Promise<void> {
  //   const livemode: boolean = payload.livemode;
  const chargeId: string = payload.id;
  const amountAuthorized: number = payload.amount;
  const amountCaptured: number = payload.amount_captured;
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

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const paymentStatus = await getPaymentStatusDocumentTransaction({transaction: transaction, paymentStatusId: paymentStatusId});
      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: paymentStatus.paymentStatusCancellationReason,
        centsAuthorized: amountAuthorized, centsCaptured: amountCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: paymentStatus.centsRequestedCapture,
        paymentStatusId: paymentStatusId, chargeId: chargeId, status: PaymentStatusStates.CHARGE_CONFIRMED});
    });
  } catch (error) {
    console.error(`Error in HandleChargeSuceeded: ${error}`);
  }
}
