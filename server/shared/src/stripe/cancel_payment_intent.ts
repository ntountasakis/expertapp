import stripe from "stripe";
import { StripeProvider } from "./stripe_provider";

export default async function cancelStripePaymentIntent({ paymentIntentId }: { paymentIntentId: string }): Promise<void> {
    let errorMessage = `PaymentIntent cancel fail for paymentIntentId: ${paymentIntentId} \n`;
    try {
        await StripeProvider.STRIPE.paymentIntents.cancel(paymentIntentId);
    } catch (error) {
        if (error instanceof stripe.errors.StripeAPIError) {
            errorMessage += `Api Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
        } else if (error instanceof stripe.errors.StripeInvalidRequestError) {
            errorMessage += `Invalid Request Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
        } else if (error instanceof stripe.errors.StripeCardError) {
            errorMessage += `Card Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
        } else if (error instanceof stripe.errors.StripeIdempotencyError) {
            errorMessage += `Idempotency Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
        } else {
            errorMessage += `Unhandled Error Type ${error}`;
        }
        throw new Error(errorMessage);
    }
}