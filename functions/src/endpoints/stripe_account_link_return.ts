import * as functions from "firebase-functions";
import {StripeProvider} from "../cloud_functions/stripe/stripe_provider";
import {createAccountLinkOnboarding, retrieveAccount} from "../cloud_functions/stripe/util";

export const stripeAccountLinkReturn = functions.https.onRequest(async (request, response) => {
  const accountId = request.query.account;
  if (typeof accountId !== "string") {
    console.log("Cannot parse account, not instance of string");
    response.status(400).end();
    return;
  }

  console.log(`Handling account link return for account ${accountId}`);
  const account = await retrieveAccount({stripe: StripeProvider.STRIPE, account: accountId});

  if (!account.payouts_enabled || !account.details_submitted) {
    let messagePrefix = `Connected account: ${accountId} still needs `;
    if (account.payouts_enabled) {
      messagePrefix += " to enable payouts ";
    }
    if (account.details_submitted) {
      messagePrefix += " to finish submitting details ";
    }
    console.warn(messagePrefix);
    const accountLink = await createAccountLinkOnboarding({stripe: StripeProvider.STRIPE, account: accountId,
      refreshUrl: StripeProvider.getAccountLinkRefreshUrl({hostname: request.hostname, account: accountId}),
      returnUrl: StripeProvider.getAccountLinkReturnUrl({hostname: request.hostname, account: accountId})});
    response.redirect(accountLink);
  } else {
    console.log(`Connected account: ${accountId} sign up process complete`);

    response.set("Content-Type", "text/html");
    // eslint-disable-next-line max-len
    response.send(Buffer.from("<p style=\x22text-align: center;\x22><strong>Sign up complete. You may close this window.</strong></p>"));
    response.status(200).end();
  }
});
