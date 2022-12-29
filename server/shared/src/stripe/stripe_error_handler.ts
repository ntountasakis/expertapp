import stripe from "stripe";

export default function handleStripeError(error: any): String {
    if (error instanceof stripe.errors.StripeAPIError) {
      return `Api Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
    } else if (error instanceof stripe.errors.StripeInvalidRequestError) {
      return `Invalid Request Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
    } else if (error instanceof stripe.errors.StripeCardError) {
      return `Card Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
    } else if (error instanceof stripe.errors.StripeIdempotencyError) {
      return `Idempotency Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
    }
    return `Unhandled Error Type ${error}`;
}