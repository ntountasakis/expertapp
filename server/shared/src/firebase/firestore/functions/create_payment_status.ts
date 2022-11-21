import { getPaymentStatusDocumentRef } from "../document_fetchers/fetchers";
import { PaymentStatus } from "../models/payment_status";

export function createPaymentStatus({transaction, uid, paymentStatusId, transferGroup, idempotencyKey, costInCents}:
    {transaction: FirebaseFirestore.Transaction, uid: string, paymentStatusId: string,
        idempotencyKey: string, transferGroup: string, costInCents: number}): PaymentStatus
{
  const callerCallStartPaymentStatus: PaymentStatus = {
    "uid": uid,
    "paymentIntentId": "",
    "status": "awaiting_payment",
    "transferGroup": transferGroup,
    "idempotencyKey": idempotencyKey,
    "centsToCollect": costInCents,
    "centsCollected": 0,
  };

  const callStartPaymentDoc = getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId});
  transaction.create(callStartPaymentDoc, callerCallStartPaymentStatus);

  console.log(`Created PaymentStatus. ID: ${paymentStatusId} CentsToCollect: ${costInCents} Uid: ${uid}`);

  return callerCallStartPaymentStatus;

}