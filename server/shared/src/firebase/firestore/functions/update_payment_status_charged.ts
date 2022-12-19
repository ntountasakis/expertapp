import { getPaymentStatusDocumentRef } from "../document_fetchers/fetchers";
import { PaymentContext, PaymentStatus, PaymentStatusStates} from "../models/payment_status";

export async function updatePaymentStatusAmountCharged({ transaction, paymentStatus, paymentStatusId, amountChargedCents: amountChargedCents}:
    { transaction: FirebaseFirestore.Transaction, paymentStatus: PaymentStatus, paymentStatusId: string, amountChargedCents: number}): Promise<void> {
    if (paymentStatus.paymentContext == PaymentContext.IN_CALL && amountChargedCents > paymentStatus.centsAuthorized) {
        console.error(`Amount authorized for PaymentStatusId: ${paymentStatusId} cents: ${paymentStatus.centsAuthorized} less than amount charged ${amountChargedCents}. Reducing to amt authorized`)
        amountChargedCents = paymentStatus.centsAuthorized;
    }
    const paymentDetails = {
        "centsCharged": amountChargedCents,
        "status": PaymentStatusStates.,
    };
    transaction.update(getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId}), paymentDetails);
}
