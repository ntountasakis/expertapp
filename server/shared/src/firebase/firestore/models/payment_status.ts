export interface PaymentStatus {
    paymentContext: PaymentContext;
    paymentStatusCancellationReason: PaymentStatusCancellationReason;
    status: PaymentStatusStates;
    uid: string;
    paymentIntentId: string;
    chargeId: string;
    transferGroup: string;
    idempotencyKey: string;
    centsRequestedAuthorized: number;
    centsAuthorized: number;
    centsRequestedCapture: number;
    centsCaptured: number;
    centsPaid: number;
}

export enum PaymentStatusStates {
    CHARGE_REQUESTED = "charge_requested", // call transaction server
    CHARGE_CONFIRMED = "charge_confirmed", // stripe webhook
    CAPTURABLE_CHANGE_REQUESTED = "capturable_change_requested", // call transaction server
    CAPTURABLE_CHANGE_CONFIRMED = "capturable_change_confirmed", // stripe webhook
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
    CALLER_ENDED_CALL_BEFORE_START = "caller_ended_call_before_start",
}
