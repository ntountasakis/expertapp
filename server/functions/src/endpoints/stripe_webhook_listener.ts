import * as functions from "firebase-functions";
import {handleChargeSuceeded} from "../stripe/handle_charge_succeeded";
import {handlePaymentAmountCaptureableUpdated} from "../stripe/handle_payment_intent_amount_captureable_updated";

export const stripeWebhookListener = functions.https.onRequest(async (request, response) => {
  try {
    const eventType = request.body.type;
    console.log(`Stripe webhook event: ${eventType}`);
    if (eventType == "payment_intent.amount_capturable_updated") {
      await handlePaymentAmountCaptureableUpdated(request.body.data.object);
    } else if (eventType == "charge.succeeded") {
      await handleChargeSuceeded(request.body.data.object);
    }
    else if (eventType == "payment_intent.failed") {
      console.log("payment intent failed");
    }
  } catch (error) {
    console.error(`Stripe webhook unknown error: ${error}`);
    response.status(500).end();
  }
  response.status(200).end();
});
