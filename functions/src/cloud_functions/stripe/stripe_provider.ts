import Stripe from "stripe";

export class StripeProvider {
  // eslint-disable-next-line max-len
  static STRIPE = new Stripe("sk_test_51LLQIdAoQ8pfRhfFWhXXPMmQkBMR1wAZSiFAc0fRZ3OQfnVJ3Mo5MXt65rv33lt0A7mzUIRWahIbSt2iFDFDrZ6C00jF2hT9eZ", {
    apiVersion: "2022-08-01",
  });

  static getAccountLinkRefreshUrl({hostname, account}: {hostname: string, account: string}): string {
    return "https://" + hostname + "/stripeAccountLinkRefresh?account=" + account;
  }

  static getAccountLinkReturnUrl({hostname, account}: {hostname: string, account: string}): string {
    return "https://" + hostname + "/stripeAccountLinkReturn?account=" + account;
  }
}
