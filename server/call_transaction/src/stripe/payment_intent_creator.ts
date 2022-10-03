import stripe from "stripe";
import { StripeProvider } from "../../../shared/stripe/stripe_provider";
import {StripeConstants} from "./constants";

export default async function createStripePaymentIntent({customerId, customerEmail,
  amountToBillInCents, paymentDescription, paymentStatusId,
  transferGroup}: {customerId: string, customerEmail: string,
    amountToBillInCents: number, paymentDescription: string, paymentStatusId: string,
    transferGroup: string}):
    Promise<[valid: boolean, errorMessage: string, paymentIntentId: string, clientSecret: string]> {

  let errorMessage = `PaymentIntent create fail for customerId: ${customerId} \n`;

  if (paymentDescription.length > StripeConstants.MAX_PAYMENT_INTENT_DESCRIPTION_LENGTH) {
    errorMessage += `Payment descripton too long. Length :${paymentDescription.length} > 
        Max length: ${StripeConstants.MAX_PAYMENT_INTENT_DESCRIPTION_LENGTH}`;
    return [false, errorMessage, "", ""];
  }
  try {
    const paymentIntentResponse = await StripeProvider.STRIPE.paymentIntents.create({
      customer: customerId,
      amount: amountToBillInCents,
      currency: "usd",
      payment_method_types: ["card"],
      receipt_email: customerEmail,
      statement_descriptor: paymentDescription,
      transfer_group: transferGroup,
      metadata: {
        "payment_status_id": paymentStatusId,
      },
    });
    if (paymentIntentResponse.client_secret != null) {
      return [true, "", paymentIntentResponse.id, paymentIntentResponse.client_secret];
    }
    errorMessage += "Null client_secret";
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
  }
  return [false, errorMessage, "", ""];
}
