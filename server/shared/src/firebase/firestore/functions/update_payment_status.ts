
import { getPaymentStatusDocumentRef } from "../document_fetchers/fetchers";
import { PaymentStatusCancellationReason, PaymentStatusStates } from "../models/payment_status";

export async function updatePaymentStatus({ transaction, paymentStatusCancellationReason, centsRequestedAuthorized,
    centsAuthorized, centsRequestedCapture, centsCaptured, centsPaid, status, paymentStatusId, chargeId }:
    {
        transaction: FirebaseFirestore.Transaction, paymentStatusCancellationReason: PaymentStatusCancellationReason,
        centsRequestedAuthorized: number, centsAuthorized: number, centsRequestedCapture: number, centsCaptured: number, centsPaid: number,
        status: PaymentStatusStates, paymentStatusId: string, chargeId: string,
    }): Promise<void> {
    const paymentDetails = {
        "chargeId": chargeId,
        "paymentStatusCancellationReason": paymentStatusCancellationReason,
        "status": status,
        "centsRequestedAuthorized": centsRequestedAuthorized,
        "centsAuthorized": centsAuthorized,
        "centsRequestedCapture": centsRequestedCapture,
        "centsCaptured": centsCaptured,
        "centsPaid": centsPaid,
    };
    transaction.update(getPaymentStatusDocumentRef({ paymentStatusId: paymentStatusId }), paymentDetails);
}
