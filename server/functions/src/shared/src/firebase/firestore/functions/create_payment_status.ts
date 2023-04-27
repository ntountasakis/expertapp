import {Logger} from "../../../google_cloud/google_cloud_logger";
import {getPaymentStatusDocumentRef} from "../document_fetchers/fetchers";
import {PaymentContext, PaymentStatus, PaymentStatusCancellationReason, PaymentStatusStates} from "../models/payment_status";

export function createPaymentStatus({transaction, callTransactionId, uid, paymentStatusId, transferGroup, idempotencyKey,
  centsRequestedAuthorized, centsRequestedCapture, paymentContext}: {
    transaction: FirebaseFirestore.Transaction, callTransactionId: string, uid: string, paymentStatusId: string,
    idempotencyKey: string, transferGroup: string, centsRequestedAuthorized: number,
    centsRequestedCapture: number, paymentContext: PaymentContext
  }): PaymentStatus {
  const callerCallStartPaymentStatus: PaymentStatus = {
    "paymentContext": paymentContext,
    "paymentStatusCancellationReason": PaymentStatusCancellationReason.NOT_CANCELLED,
    "uid": uid,
    "paymentIntentId": "",
    "chargeId": "",
    "status": PaymentStatusStates.CHARGE_REQUESTED,
    "transferGroup": transferGroup,
    "idempotencyKey": idempotencyKey,
    "centsRequestedAuthorized": centsRequestedAuthorized,
    "centsAuthorized": 0,
    "centsRequestedCapture": centsRequestedCapture,
    "centsPaid": 0,
    "centsCaptured": 0,
  };

  const callStartPaymentDoc = getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId});
  transaction.create(callStartPaymentDoc, callerCallStartPaymentStatus);

  Logger.log({
    logName: Logger.CALL_SERVER, message: `Created PaymentStatus. ID: ${paymentStatusId} CentsRequestedAuthorized: ${centsRequestedAuthorized} Uid: ${uid}`,
    labels: new Map([["userId", uid], ["callTransactionId", callTransactionId]]),
  });

  return callerCallStartPaymentStatus;
}
