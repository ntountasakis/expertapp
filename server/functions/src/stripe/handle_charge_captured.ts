import * as admin from "firebase-admin";
import {getPaymentStatusDocumentTransaction} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {updatePaymentStatus} from "../../../shared/src/firebase/firestore/functions/update_payment_status";
import {PaymentStatusStates} from "../../../shared/src/firebase/firestore/models/payment_status";

export async function handleChargeCaptured(payload: any): Promise<void> {
  //   const livemode: boolean = payload.livemode;
  const amountCaptured: number = payload.amount_captured;
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

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const paymentStatus = await getPaymentStatusDocumentTransaction({transaction: transaction, paymentStatusId: paymentStatusId});
      // the final payment indication can come out of order with charge captured, but paid is the final state we care about
      const status = paymentStatus.status == PaymentStatusStates.PAID ? PaymentStatusStates.PAID : PaymentStatusStates.CAPTURABLE_CHANGE_CONFIRMED;
      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: paymentStatus.paymentStatusCancellationReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: amountCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: paymentStatus.centsRequestedCapture,
        paymentStatusId: paymentStatusId, chargeId: paymentStatus.chargeId, status: status});
    });
  } catch (error) {
    console.error(`Error in PaymentIntentAmountCapturableUpdated: ${error}`);
  }
}
