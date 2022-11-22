import Stripe from "stripe";

export class StripeProvider {
  static API_VERSION = "2022-08-01" as Stripe.LatestApiVersion;
  static STRIPE = new Stripe("sk_test_51LLQIdAoQ8pfRhfFWhXXPMmQkBMR1wAZSiFAc0fRZ3OQfnVJ3Mo5MXt65rv33lt0A7mzUIRWahIbSt2iFDFDrZ6C00jF2hT9eZ", {
    apiVersion: StripeProvider.API_VERSION,
  });

  static getAccountLinkRefreshUrl({ hostname, account }: { hostname: string, account: string }): string {
    return "https://" + hostname + "/stripeAccountLinkRefresh?account=" + account;
  }

  static getAccountLinkReturnUrl({ hostname, account }: { hostname: string, account: string }): string {
    return "https://" + hostname + "/stripeAccountLinkReturn?account=" + account;
  }
}
