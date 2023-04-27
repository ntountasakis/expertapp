import handleStripeError from "./stripe_error_handler";
import {StripeProvider} from "./stripe_provider";

export default async function cancelStripePaymentIntent({paymentIntentId}: { paymentIntentId: string }): Promise<void> {
  let errorMessage = `PaymentIntent cancel fail for paymentIntentId: ${paymentIntentId} \n`;
  try {
    await StripeProvider.STRIPE.paymentIntents.cancel(paymentIntentId);
  } catch (error) {
    errorMessage += handleStripeError("cancelStripePaymentIntent", error);
    throw new Error(errorMessage);
  }
}
