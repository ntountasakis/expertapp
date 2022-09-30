import Stripe from "stripe";
import {StripeConstants} from "./constants";

export default async function createStripePaymentIntent(customerId: string, customerEmail: string,
    amountToBillInCents: number, paymentDescription: string, paymentStatusId: string):
    Promise<[valid: boolean, errorMessage: string, paymentIntentId: string, clientSecret: string]> {
  const stripe = new Stripe("sk_test_51LLQIdAoQ8pfRhfFWhXXPMmQkBMR1wAZSiFAc0fRZ3OQfnVJ3Mo5MXt65rv33lt0A7mzUIRWahIbSt2iFDFDrZ6C00jF2hT9eZ", {
    apiVersion: "2020-08-27",
  });

  let errorMessage = `PaymentIntent create fail for customerId: ${customerId} \n`;

  if (paymentDescription.length > StripeConstants.MAX_PAYMENT_INTENT_DESCRIPTION_LENGTH) {
    errorMessage += `Payment descripton too long. Length :${paymentDescription.length} > 
        Max length: ${StripeConstants.MAX_PAYMENT_INTENT_DESCRIPTION_LENGTH}`;
    return [false, errorMessage, "", ""];
  }
  try {
    const paymentIntentResponse = await stripe.paymentIntents.create({
      customer: customerId,
      amount: amountToBillInCents,
      currency: "usd",
      payment_method_types: ["card"],
      receipt_email: customerEmail,
      statement_descriptor: paymentDescription,
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
