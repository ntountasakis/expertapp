import Stripe from "stripe";
import {StripeConstants} from "./constants";
import handleStripeError from "./stripe_error_handler";
import {StripeProvider} from "./stripe_provider";

export async function createStripePaymentIntentPreAuth({customerId, customerEmail,
  amountToAuthInCents: amountToAuthInCents, paymentDescription, idempotencyKey,
  transferGroup, paymentStatusId, callerUid, calledUid, callTransactionId}: {
    customerId: string, customerEmail: string,
    amountToAuthInCents: number, paymentDescription: string, idempotencyKey: string,
    transferGroup: string, paymentStatusId: string, callerUid: string, calledUid: string,
    callTransactionId: string,
  }):
  Promise<[paymentIntentId: string, clientSecret: string]> {
  return paymentIntentCreateHelper({
    customerId: customerId, customerEmail: customerEmail,
    amountCents: amountToAuthInCents, paymentDescription: paymentDescription,
    idempotencyKey: idempotencyKey, transferGroup: transferGroup, paymentStatusId: paymentStatusId,
    callerUid: callerUid, captureMethod: "manual", calledUid: calledUid, callTransactionId: callTransactionId,
  });
}

export async function createStripePaymentIntentImmediate({customerId, customerEmail,
  amountToRequestInCents: amountToRequestInCents, paymentDescription, idempotencyKey,
  transferGroup, paymentStatusId, callerUid, calledUid, callTransactionId}: {
    customerId: string, customerEmail: string,
    amountToRequestInCents: number, paymentDescription: string, idempotencyKey: string,
    transferGroup: string, paymentStatusId: string, callerUid: string, calledUid: string,
    callTransactionId: string,
  }):
  Promise<[paymentIntentId: string, clientSecret: string]> {
  return paymentIntentCreateHelper({
    customerId: customerId, customerEmail: customerEmail,
    amountCents: amountToRequestInCents, paymentDescription: paymentDescription,
    idempotencyKey: idempotencyKey, transferGroup: transferGroup, paymentStatusId: paymentStatusId,
    callerUid: callerUid, captureMethod: "automatic", calledUid: calledUid, callTransactionId: callTransactionId,
  });
}

export async function chargeStripePaymentIntent({amountToCaptureInCents, paymentIntentId}:
  { amountToCaptureInCents: number, paymentIntentId: string }): Promise<string> {
  let errorMessage = `Unable to charge payment intent for paymentIntentId: ${paymentIntentId} \n`;
  try {
    const capture = await StripeProvider.STRIPE.paymentIntents.capture(
        paymentIntentId, {
          amount_to_capture: amountToCaptureInCents,
        });
    if (capture.client_secret != null) {
      return capture.client_secret;
    }
  } catch (error) {
    errorMessage += handleStripeError("chargeStripePaymentIntent", error);
  }
  throw new Error(errorMessage);
}

async function paymentIntentCreateHelper({customerId, customerEmail,
  amountCents: amountCents, paymentDescription, idempotencyKey,
  transferGroup, paymentStatusId, callerUid, captureMethod: captureMethod,
  calledUid, callTransactionId}: {
    customerId: string, customerEmail: string,
    amountCents: number, paymentDescription: string, idempotencyKey: string,
    transferGroup: string, paymentStatusId: string, callerUid: string,
    calledUid: string,
    captureMethod: Stripe.PaymentIntentCreateParams.CaptureMethod,
    callTransactionId: string,
  }):
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
      setup_future_usage: "on_session",
      amount: amountCents,
      currency: "usd",
      receipt_email: customerEmail,
      statement_descriptor: paymentDescription,
      transfer_group: transferGroup,
      automatic_payment_methods: {
        enabled: true,
      },
      capture_method: captureMethod,
      metadata: {
        "payment_status_id": paymentStatusId,
        "caller_uid": callerUid,
        "called_uid": calledUid,
        "call_transaction_id": callTransactionId,
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
    errorMessage += handleStripeError("paymentIntentCreateHelper", error);
  }
  throw new Error(errorMessage);
}
