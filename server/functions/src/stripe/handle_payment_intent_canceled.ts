import * as admin from "firebase-admin";
import {getPaymentStatusDocumentTransaction} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {updatePaymentStatus} from "../../../shared/src/firebase/firestore/functions/update_payment_status";
import {PaymentStatusStates} from "../../../shared/src/firebase/firestore/models/payment_status";

export async function handlePaymentIntentCanceled(payload: any): Promise<void> {
  //   const livemode: boolean = payload.livemode;
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

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const paymentStatus = await getPaymentStatusDocumentTransaction({transaction: transaction, paymentStatusId: paymentStatusId});
      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: paymentStatus.paymentStatusCancellationReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: paymentStatus.centsCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: paymentStatus.centsRequestedCapture,
        paymentStatusId: paymentStatusId, status: PaymentStatusStates.CANCELLATION_CONFIRMED});
    });
  } catch (error) {
    console.error(`Error in HandlePaymentIntentSuceeded: ${error}`);
  }
}
