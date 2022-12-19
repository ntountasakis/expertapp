import { getPaymentStatusDocumentRef } from "../document_fetchers/fetchers";
import { PaymentStatusCancellationReason, PaymentStatusStates } from "../models/payment_status";

export async function updatePaymentStatusCancelled({ transaction, paymentStatusId, reason }:
    { transaction: FirebaseFirestore.Transaction, paymentStatusId: string, reason: PaymentStatusCancellationReason }): Promise<void> {
    const paymentDetails = {
        "paymentStatusCancellationReason": reason,
        "status": PaymentStatusStates.CANCELLATION_CONFIRMED,
    };
    transaction.update(getPaymentStatusDocumentRef({ paymentStatusId: paymentStatusId }), paymentDetails);
}
