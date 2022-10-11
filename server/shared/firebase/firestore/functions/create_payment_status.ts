import { getPaymentStatusDocumentRef } from "../document_fetchers/fetchers";
import { PaymentStatus } from "../models/payment_status";

export function createPaymentStatus({transaction, uid, paymentStatusId, transferGroup, costInCents}:
    {transaction: FirebaseFirestore.Transaction, uid: string, paymentStatusId: string,
        transferGroup: string, costInCents: number})
{
  const callerCallStartPaymentStatus: PaymentStatus = {
    "uid": uid,
    "status": "awaiting_payment",
    "transferGroup": transferGroup,
    "centsToCollect": costInCents,
    "centsCollected": 0,
  };

  const callStartPaymentDoc = getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId});
  transaction.create(callStartPaymentDoc, callerCallStartPaymentStatus);

  console.log(`Created PaymentStatus. ID: ${paymentStatusId} CentsToCollect: ${costInCents} Uid: ${uid}`);

}