export interface PaymentStatus {
    paymentContext: PaymentContext;
    paymentStatusCancellationReason: PaymentStatusCancellationReason;
    uid: string;
    paymentIntentId: string;
    status: string;
    transferGroup: string;
    idempotencyKey: string;
    centsRequestedAuthorized: number;
    centsAuthorized: number;
    centsCharged: number;
    centsCaptured: number;
    centsPaid: number;
}

export enum PaymentStatusStates {
    PRE_AUTH_REQUESTED = "pre_auth_requested", // call transaction server
    PRE_AUTH_CONFIRMED = "pre_auth_confirmed", // stripe webhook
    CHARGE_REQUESTED = "charge_requested", // call transaction server
    CHARGE_CONFIRMED = "charge_confirmed", // stripe webhook
    PAID = "paid", // stripe webhook
    CANCELLATION_REQUESTED = "cancellation_requested", // call transaction server
    CANCELLATION_CONFIRMED = "cancellation_confirmed", // stripe webhook
}

export enum PaymentContext {
    PAY_OUTSTANDING_BALANCE = "pay_outstanding_balance",
    IN_CALL = "in_call",
}

export enum PaymentStatusCancellationReason {
    NOT_CANCELLED = "not_cancelled",
    CALLED_NEVER_JOINED = "called_never_joined",
}
