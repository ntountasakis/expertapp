import * as functions from "firebase-functions";
import {StripeProvider} from "../../../shared/src/stripe/stripe_provider";
import {createAccountLinkOnboarding} from "../../../shared/src/stripe/util";
import {createOrFetchStripeConnectedAccountId} from "../stripe/create_stripe_connected_account";

export const stripeAccountLinkRefresh = functions.https.onRequest(async (request, response) => {
  const uid = request.query.uid;
  const token = request.query.token;
  if (typeof uid !== "string") {
    console.log(`Cannot parse uid, not instance of string. Type: ${typeof uid}`);
    response.status(400);
    return;
  }
  if (typeof token === "string") {
    console.log(`User provided token: ${token}`);
    console.log(`Handling account link refresh for uid ${uid}`);

    const account: string = await createOrFetchStripeConnectedAccountId({uid: uid});
    const accountLink = await createAccountLinkOnboarding({stripe: StripeProvider.STRIPE, account: account as string,
      refreshUrl: StripeProvider.getAccountLinkRefreshUrl({hostname: request.hostname, uid: uid}),
      returnUrl: StripeProvider.getAccountLinkReturnUrl({hostname: request.hostname, uid: uid}),
    });
    response.redirect(accountLink);
  } else {
    console.log(`Redirecting to token submit for uid ${uid}`);
    response.redirect(StripeProvider.getAccountTokenSubmitUrl({hostname: request.hostname, uid: uid}));
  }
});
