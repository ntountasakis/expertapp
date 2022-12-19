import { getPaymentStatusDocumentRef } from "../document_fetchers/fetchers";
import { PaymentStatusStates } from "../models/payment_status";

export async function updatePaymentStatusAmountPaid({ transaction, paymentStatusId, amountPaidCents: amountPaidCents}:
    { transaction: FirebaseFirestore.Transaction, paymentStatusId: string, amountPaidCents: number}): Promise<void> {
    const paymentDetails = {
        "centsPaid": amountPaidCents,
        "status": PaymentStatusStates.PAID,
    };
    transaction.update(getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId}), paymentDetails);
}
