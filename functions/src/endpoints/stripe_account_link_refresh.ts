import * as functions from "firebase-functions";
import {StripeProvider} from "../cloud_functions/stripe/stripe_provider";
import {createAccountLinkOnboarding} from "../cloud_functions/stripe/util";

export const stripeAccountLinkRefresh = functions.https.onRequest(async (request, response) => {
  const account = request.query.account;
  if (typeof account !== "string") {
    console.log(`Cannot parse account, not instance of string. Type: ${typeof account}`);
    response.status(400);
    return;
  }
  console.log(`Handling account link refresh for account ${account}`);

  const accountLink = await createAccountLinkOnboarding({stripe: StripeProvider.STRIPE, account: account as string,
    refreshUrl: StripeProvider.getAccountLinkRefreshUrl({hostname: request.hostname, account: account}),
    returnUrl: StripeProvider.getAccountLinkReturnUrl({hostname: request.hostname, account: account}),
  });

  response.redirect(accountLink);
});
