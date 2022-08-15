export class StripePaymentIntentStatus {
    static REQUIRES_PAYMENT_METHOD ="required_payment_method";
    static REQUIRES_CONFIRMATION = "requires_confirmation";
    static REQUIRES_ACTION = "requires_action";
    static REQUIRES_CAPTURE = "requires_capture";
    static CANCELED = "canceled";
    static SUCCEEDED = "succeeded";
}
