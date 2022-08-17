export class StripeConstants {
    static MAX_PAYMENT_INTENT_DESCRIPTION_LENGTH = 25
}

export class StripePaymentIntentStates {
    static REQUIRES_PAYMENT_METHOD = "requires_payment_method";
    static REQUIRES_CONFIRMATION = "requires_confirmation";
    static REQUIRES_ACTION = "requires_action";
    static PROCESSING = "processing";
    static REQUIRES_CAPTURE = "requires_capture";
    static CANCELED = "canceled";
    static SUCCEEDED = "succeeded";
}
