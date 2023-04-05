import Stripe from "stripe";
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

export class StripeProvider {
  static API_VERSION = "2022-08-01" as Stripe.LatestApiVersion;

  static STRIPE_CONFIGURED = false;
  static STRIPE: Stripe;

  static PLATFORM_PERCENT_FEE = 8.0;
  static STRIPE_PERCENT_FEE = 2.9;
  static STRIPE_FLAT_FEE_CENTS = 30;
  static MIN_BILLABLE_AMOUNT_CENTS = 50;

  static async getStripeSecret(stripePrivateKeyVersion: string): Promise<string> {
    const client = new SecretManagerServiceClient();
    const privateKeyString = "projects/expert-app-backend/secrets/stripe-private-key/versions/" + stripePrivateKeyVersion;
    const [version] = await client.accessSecretVersion({
      name: privateKeyString,
    });
    if (version.payload === undefined || version.payload!.data === undefined) {
      throw new Error("Cannot get stripe private key from secret manager");
    }
    const payload = version.payload!.data!.toString();
    return payload;
  }

  static async configureStripe(stripePrivateKeyVersion?: string): Promise<void> {
    if (stripePrivateKeyVersion === undefined || stripePrivateKeyVersion === null) {
      throw new Error("Stripe private key version is not defined");
    }
    if (!StripeProvider.STRIPE_CONFIGURED) {
      const stripeKey = await this.getStripeSecret(stripePrivateKeyVersion!);
      StripeProvider.STRIPE = new Stripe(stripeKey, {
        apiVersion: StripeProvider.API_VERSION,
      });
      StripeProvider.STRIPE_CONFIGURED = true;
    }
  }

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

