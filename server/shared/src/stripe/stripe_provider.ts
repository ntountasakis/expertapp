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

  static getHttpSuffix({ endpoint, uid }: { endpoint: string, uid: string }) {
    return endpoint + "?uid=" + uid;
  }

  static getAccountLinkRefreshUrl({ hostname, uid }: { hostname: string, uid: string }): string {
    return this.getHttpPrefix({ hostname: hostname }) + this.getHttpSuffix({ endpoint: "stripeAccountLinkRefresh", uid: uid });
  }

  static getAccountLinkReturnUrl({ hostname, uid }: { hostname: string, uid: string }): string {
    return this.getHttpPrefix({ hostname: hostname }) + this.getHttpSuffix({ endpoint: "stripeAccountLinkReturn", uid: uid });
  }

  static getAccountTokenSubmitUrl({ hostname, uid, tokenInvalid }: { hostname: string, uid: string, tokenInvalid: boolean }): string {
    let url = this.getHttpPrefix({ hostname: hostname }) + this.getHttpSuffix({ endpoint: "stripeAccountTokenSubmit", uid: uid });
    if (tokenInvalid) {
      url += '&tokenInvalid=true';
    }
    return url;
  }
}
function isRunningInEmulator() {
  return process.env.FUNCTIONS_EMULATOR === "true";
}

