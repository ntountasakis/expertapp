export interface PaymentStatus
{
    uid: string;
    status: string;
    transferGroup: string;
    centsToCollect: number;
    centsCollected: number;
}
