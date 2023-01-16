import Stripe from "stripe";

export class StripeProvider {
  static API_VERSION = "2022-08-01" as Stripe.LatestApiVersion;
  static STRIPE = new Stripe("sk_test_51LLQIdAoQ8pfRhfFWhXXPMmQkBMR1wAZSiFAc0fRZ3OQfnVJ3Mo5MXt65rv33lt0A7mzUIRWahIbSt2iFDFDrZ6C00jF2hT9eZ", {
    apiVersion: StripeProvider.API_VERSION,
  });

  static PLATFORM_PERCENT_FEE = 8.0;
  static STRIPE_PERCENT_FEE = 2.9;
  static STRIPE_FLAT_FEE_CENTS = 30;

  static getHttpPrefix({ hostname }: { hostname: string }) {
    // this should be localhost if running in iOS emulator
    if (isRunningInEmulator()) {
      return 'http://10.0.2.2:9001/' + process.env.GCLOUD_PROJECT + '/us-central1/';
    }
    return isRunningInEmulator() ? "http://10.0.2.2:9001" : "https://" + hostname + '/';
  }

  static getHttpSuffix({ endpoint, account }: { endpoint: string, account: string }) {
    return endpoint + "?account=" + account;
  }

  static getAccountLinkRefreshUrl({ hostname, account }: { hostname: string, account: string }): string {
    return this.getHttpPrefix({ hostname: hostname }) + this.getHttpSuffix({ endpoint: "stripeAccountLinkRefresh", account: account });
  }

  static getAccountLinkReturnUrl({ hostname, account }: { hostname: string, account: string }): string {
    return this.getHttpPrefix({ hostname: hostname }) + this.getHttpSuffix({ endpoint: "stripeAccountLinkReturn", account: account });
  }
}
function isRunningInEmulator() {
  return process.env.FUNCTIONS_EMULATOR === "true";
}

