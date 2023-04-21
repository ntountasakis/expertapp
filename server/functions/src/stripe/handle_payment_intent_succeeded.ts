import * as admin from "firebase-admin";
import {getPaymentStatusDocumentTransaction} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {updatePaymentStatus} from "../../../shared/src/firebase/firestore/functions/update_payment_status";
import {PaymentStatusStates} from "../../../shared/src/firebase/firestore/models/payment_status";
import {Logger} from "../../../shared/src/google_cloud/google_cloud_logger";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function handlePaymentIntentSucceeded(payload: any): Promise<void> {
  //   const livemode: boolean = payload.livemode;
  const amountPaid: number = payload.amount_received;
  const paymentStatusId: string = payload.metadata.payment_status_id;
  const callerUid: string = payload.metadata.caller_uid;

  if (paymentStatusId == undefined) {
    Logger.logError({
      logName: "handlePaymentIntentSucceeded", message: "Cannot handle PaymentIntent Success. PaymentStatusId undefined",
    });
    return;
  }
  if (callerUid == undefined) {
    Logger.logError({
      logName: "handlePaymentIntentSucceeded", message: "Cannot handle PaymentIntent Success. CallerUid undefined",
      labels: new Map([["paymentStatusId", paymentStatusId]]),
    });
    return;
  }

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const paymentStatus = await getPaymentStatusDocumentTransaction({transaction: transaction, paymentStatusId: paymentStatusId});
      await updatePaymentStatus({
        transaction: transaction, paymentStatusCancellationReason: paymentStatus.paymentStatusCancellationReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: paymentStatus.centsCaptured, centsPaid: amountPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: paymentStatus.centsRequestedCapture,
        paymentStatusId: paymentStatusId, chargeId: paymentStatus.chargeId, status: PaymentStatusStates.PAID,
      });
    });
  } catch (error) {
    Logger.logError({
      logName: "handlePaymentIntentSucceeded", message: `Error while handling PaymentIntent Success. Error: ${error}`,
      labels: new Map([["paymentStatusId", paymentStatusId]]),
    });
  }
}
