import stripe from "stripe";
import {StripeConstants} from "./constants";
import { StripeProvider } from "./stripe_provider";

export default async function createStripePaymentIntent({customerId, customerEmail,
  amountToBillInCents, paymentDescription, idempotencyKey,
  transferGroup, paymentStatusId, uid}: {customerId: string, customerEmail: string,
    amountToBillInCents: number, paymentDescription: string, idempotencyKey: string,
    transferGroup: string, paymentStatusId: string, uid: string}):
    Promise<[paymentIntentId: string, clientSecret: string]> {
  let errorMessage = `PaymentIntent create fail for customerId: ${customerId} \n`;

  if (paymentDescription.length > StripeConstants.MAX_PAYMENT_INTENT_DESCRIPTION_LENGTH) {
    errorMessage += `Payment descripton too long. Length :${paymentDescription.length} > 
        Max length: ${StripeConstants.MAX_PAYMENT_INTENT_DESCRIPTION_LENGTH}`;
    throw new Error(errorMessage);
  }
  try {
    const paymentIntentResponse = await StripeProvider.STRIPE.paymentIntents.create({
      customer: customerId,
      setup_future_usage: 'on_session',
      amount: amountToBillInCents,
      currency: "usd",
      receipt_email: customerEmail,
      statement_descriptor: paymentDescription,
      transfer_group: transferGroup,
      automatic_payment_methods: {
        enabled: true,
      },
      metadata: {
        "payment_status_id": paymentStatusId,
        "uid": uid,
      },
    },
    {
      idempotencyKey: idempotencyKey,
    });
    if (paymentIntentResponse.client_secret != null) {
      return [paymentIntentResponse.id, paymentIntentResponse.client_secret];
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
  throw new Error(errorMessage);
}
