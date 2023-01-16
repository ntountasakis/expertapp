import * as functions from "firebase-functions";
import {StripeProvider} from "../../../shared/src/stripe/stripe_provider";
import {createAccountLinkOnboarding} from "../../../shared/src/stripe/util";
import {createStripeConnectedAccount} from "../stripe/create_stripe_connected_account";

export const stripeAccountLinkRefresh = functions.https.onRequest(async (request, response) => {
  const uid = request.query.uid;
  if (typeof uid !== "string") {
    console.log(`Cannot parse uid, not instance of string. Type: ${typeof uid}`);
    response.status(400);
    return;
  }
  console.log(`Handling account link refresh for uid ${uid}`);

  const account: string = await createStripeConnectedAccount({uid: uid});

  const accountLink = await createAccountLinkOnboarding({stripe: StripeProvider.STRIPE, account: account as string,
    refreshUrl: StripeProvider.getAccountLinkRefreshUrl({hostname: request.hostname, account: account}),
    returnUrl: StripeProvider.getAccountLinkReturnUrl({hostname: request.hostname, account: account}),
  });

  response.redirect(accountLink);
});
