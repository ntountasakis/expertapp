import * as functions from "firebase-functions";
import {handlePaymentIntentSucceeded} from "../cloud_functions/stripe/webhook/handle_payment_intent_succeeded";

export const stripeWebhookListener = functions.https.onRequest(async (request, response) => {
  try {
    const eventType = request.body.type;
    console.log(`Stripe webhook event: ${eventType}`);
    if (eventType == "payment_intent.succeeded") {
      await handlePaymentIntentSucceeded(request.body.data.object);
    } else if (eventType == "payment_intent.failed") {
      console.log("payment intent failed");
    }
  } catch (error) {
    console.error(`Stripe webhook unknown error: ${error}`);
    response.status(500).end();
  }
  response.status(200).end();
});
