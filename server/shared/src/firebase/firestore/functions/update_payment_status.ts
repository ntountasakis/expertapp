import { getPaymentStatusDocumentRef } from "../document_fetchers/fetchers";

export async function updatePaymentStatus({transaction, paymentStatusId, amountReceived, status}:
    {transaction: FirebaseFirestore.Transaction, paymentStatusId: string, amountReceived: number,
    status: string}): Promise<void> {
  const paymentStatusDoc = await transaction.get(getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId}));

  if (!paymentStatusDoc.exists) {
    throw new Error(`Cannot update PaymentStatus! PaymentIntentId: ${paymentStatusId} not found.`);
  }
  const paymentDetails = {
    "centsCollected": amountReceived,
    "status": status,
  };
  transaction.update(paymentStatusDoc.ref, paymentDetails);
}
