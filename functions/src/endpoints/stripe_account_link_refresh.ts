import * as functions from "firebase-functions";
import Stripe from "stripe";
import {createAccountLinkOnboarding} from "../cloud_functions/stripe/util";

export const stripeAccountLinkRefresh = functions.https.onRequest(async (request, response) => {
  const account = request.query.account;
  if (typeof account !== "string") {
    console.log(`Cannot parse account, not instance of string. Type: ${typeof account}`);
    response.status(400);
    return;
  }
  console.log(`Handling account link refresh for account ${account}`);

  // eslint-disable-next-line max-len
  const stripe = new Stripe("sk_test_51LLQIdAoQ8pfRhfFWhXXPMmQkBMR1wAZSiFAc0fRZ3OQfnVJ3Mo5MXt65rv33lt0A7mzUIRWahIbSt2iFDFDrZ6C00jF2hT9eZ", {
    apiVersion: "2022-08-01",
  });
  const refreshUrl = "https://" + request.hostname + "/stripeAccountLinkRefresh?account=" + account;
  const returnUrl = "https://" + request.hostname + "/stripeAccountLinkReturn?account=" + account;
  const accountLink = await createAccountLinkOnboarding({stripe: stripe, account: account as string,
    refreshUrl: refreshUrl, returnUrl: returnUrl});

  console.log(`Redirecting client to one-time account link: ${accountLink} with refreshUrl ${refreshUrl} and
  returnUrl ${returnUrl}`);
  response.redirect(accountLink);
});
