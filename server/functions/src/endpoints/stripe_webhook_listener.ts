import * as functions from "firebase-functions";
import {handleChargeSuceeded} from "../stripe/handle_charge_succeeded";
import {handleChargeCaptured} from "../stripe/handle_charge_captured";
import {handlePaymentIntentCanceled} from "../stripe/handle_payment_intent_canceled";
import {handlePaymentIntentSucceeded} from "../stripe/handle_payment_intent_succeeded";

export const stripeWebhookListener = functions.https.onRequest(async (request, response) => {
  try {
    const eventType = request.body.type;
    console.log(`Stripe webhook event: ${eventType}`);
    if (eventType == "charge.succeeded") {
      await handleChargeSuceeded(request.body.data.object);
    } else if (eventType == "charge.captured") {
      await handleChargeCaptured(request.body.data.object);
    } else if (eventType == "payment_intent.succeeded") {
      await handlePaymentIntentSucceeded(request.body.data.object);
    } else if (eventType == "payment_intent.canceled") {
      await handlePaymentIntentCanceled(request.body.data.object);
    }
  } catch (error) {
    console.error(`Stripe webhook unknown error: ${error}`);
    response.status(500).end();
  }
  response.status(200).end();
});
