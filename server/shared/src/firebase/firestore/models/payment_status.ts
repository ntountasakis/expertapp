export interface PaymentStatus
{
    uid: string;
    paymentIntentId: string;
    status: string;
    transferGroup: string;
    idempotencyKey: string;
    centsToCollect: number;
    centsCollected: number;
}
