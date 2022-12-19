import { getPaymentStatusDocumentRef } from "../document_fetchers/fetchers";
import { PaymentStatus, PaymentStatusStates } from "../models/payment_status";

export async function updatePaymentStatusAmountAuthorized({ transaction, paymentStatusId, amountReceived: centsAmtAuthorized, status }:
    { transaction: FirebaseFirestore.Transaction, paymentStatusId: string, amountReceived: number, status: PaymentStatusStates }): Promise<void> {
    const paymentStatusDoc = await transaction.get(getPaymentStatusDocumentRef({ paymentStatusId: paymentStatusId }));
    if (!paymentStatusDoc.exists) {
        throw new Error(`Cannot update payment status amount authorized! PaymentStatusId: ${paymentStatusId} not found.`);
    }
    const paymentData: PaymentStatus = paymentStatusDoc.data() as PaymentStatus;
    if (paymentData.centsRequestedAuthorized != centsAmtAuthorized) {
        throw new Error(`Amount authorized for PaymentStatusId: ${paymentStatusId} cents: ${centsAmtAuthorized} differs than requested ${paymentData.centsRequestedAuthorized}`);
    }
    const paymentDetails = {
        "centsAuthorized": centsAmtAuthorized,
        "status": status,
    };
    transaction.update(paymentStatusDoc.ref, paymentDetails);
}
