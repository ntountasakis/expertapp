import * as functions from "firebase-functions";
import Stripe from "stripe";
import {createAccountLinkOnboarding} from "../cloud_functions/stripe/util";

export const stripeAccountLinkReauth = functions.https.onRequest(async (request, response) => {
  const account = request.query.account;
  if (account instanceof String) {
    console.log("Cannot parse account, not instance of string");
    response.status(400);
    return;
  }

  // eslint-disable-next-line max-len
  const stripe = new Stripe("sk_test_51LLQIdAoQ8pfRhfFWhXXPMmQkBMR1wAZSiFAc0fRZ3OQfnVJ3Mo5MXt65rv33lt0A7mzUIRWahIbSt2iFDFDrZ6C00jF2hT9eZ", {
    apiVersion: "2022-08-01",
  });
  const refreshUrl = "https://" + request.hostname + "/stripeAccountLinkReauth?account=" + account;
  const returnUrl = "https://example.com/return";
  const accountLink = await createAccountLinkOnboarding({stripe: stripe, account: account as string,
    refreshUrl: refreshUrl, returnUrl: returnUrl});

  console.log(`Redirecting client to one-time account link: ${accountLink} with refreshUrl ${refreshUrl}`);
  response.redirect(accountLink);
});
