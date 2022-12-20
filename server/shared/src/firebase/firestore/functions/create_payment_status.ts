import { getPaymentStatusDocumentRef } from "../document_fetchers/fetchers";
import { PaymentContext, PaymentStatus, PaymentStatusCancellationReason, PaymentStatusStates } from "../models/payment_status";

export function createPaymentStatus({ transaction, uid, paymentStatusId, transferGroup, idempotencyKey,
  centsRequestedAuthorized: centsRequestedAuthorized, centsRequestedCapture }: {
    transaction: FirebaseFirestore.Transaction, uid: string, paymentStatusId: string,
    idempotencyKey: string, transferGroup: string, centsRequestedAuthorized: number,
    centsRequestedCapture: number,
  }): PaymentStatus {
  const callerCallStartPaymentStatus: PaymentStatus = {
    "paymentContext": PaymentContext.IN_CALL,
    "paymentStatusCancellationReason": PaymentStatusCancellationReason.NOT_CANCELLED,
    "uid": uid,
    "paymentIntentId": "",
    "status": PaymentStatusStates.CHARGE_REQUESTED,
    "transferGroup": transferGroup,
    "idempotencyKey": idempotencyKey,
    "centsRequestedAuthorized": centsRequestedAuthorized,
    "centsAuthorized": centsRequestedAuthorized,
    "centsRequestedCapture": centsRequestedCapture,
    "centsPaid": 0,
    "centsCaptured": 0,
  };

  const callStartPaymentDoc = getPaymentStatusDocumentRef({ paymentStatusId: paymentStatusId });
  transaction.create(callStartPaymentDoc, callerCallStartPaymentStatus);

  console.log(`Created PaymentStatus. ID: ${paymentStatusId} CentsRequestedAuthorized: ${centsRequestedAuthorized} Uid: ${uid}`);

  return callerCallStartPaymentStatus;

}