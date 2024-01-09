import Stripe from "stripe";
import {SecretManagerServiceClient} from "@google-cloud/secret-manager";
import {GoogleCloudProvider} from "../google_cloud/google_cloud_provider";
import {Logger} from "../google_cloud/google_cloud_logger";

export class StripeProvider {
  static API_VERSION = "2022-11-15" as Stripe.LatestApiVersion;

  static STRIPE_CONFIGURED = false;
  static STRIPE: Stripe;

  /* document on stripe fees: https://stripe.com/pricing */
  /* not used in this application, but will deduct from our profit */
  static STRIPE_PERCENT_FEE = 2.9;
  static STRIPE_FLAT_FEE_CENTS = 30;

  static PLATFORM_PERCENT_FEE = 15.0;
  static MIN_BILLABLE_AMOUNT_CENTS = 50;
  static MAX_MINUTELY_RATE_CENTS = 500;
  static MAX_START_CALL_RATE_CENTS = 10 * 100;

  static async getStripeSecret(stripePrivateKeyVersion: string): Promise<string> {
    const client = new SecretManagerServiceClient();
    const privateKeyString = GoogleCloudProvider.STRIPE_PRIVATE_KEY_PREFIX + stripePrivateKeyVersion;
    const [version] = await client.accessSecretVersion({
      name: privateKeyString,
    });
    if (version.payload === undefined || version.payload?.data === undefined) {
      const errorMsg = "Cannot get stripe private key from secret manager";
      Logger.logError({logName: "StripeProvider", message: errorMsg});
      throw new Error(errorMsg);
    }
    const payload = version.payload?.data?.toString();
    if (payload == undefined) {
      throw new Error("Stripe private key is undefined");
    }
    return payload;
  }

  static async configureStripe(stripePrivateKeyVersion?: string): Promise<void> {
    if (stripePrivateKeyVersion === undefined || stripePrivateKeyVersion === null) {
      const errorMsg = "Stripe private key version is not defined";
      Logger.logError({logName: "StripeProvider", message: errorMsg});
      throw new Error(errorMsg);
    }
    if (!StripeProvider.STRIPE_CONFIGURED) {
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      const stripeKey = await this.getStripeSecret(stripePrivateKeyVersion!);
      StripeProvider.STRIPE = new Stripe(stripeKey, {
        apiVersion: StripeProvider.API_VERSION,
      });
      StripeProvider.STRIPE_CONFIGURED = true;
    }
  }

  static getHttpPrefix({hostname}: { hostname: string }) {
    // this should be localhost if running in iOS emulator
    if (isRunningInEmulator()) {
      return "http://10.0.2.2:9001/" + process.env.GCLOUD_PROJECT + "/us-central1/";
    }
    return isRunningInEmulator() ? "http://10.0.2.2:9001" : "https://" + hostname + "/";
  }

  static getHttpSuffix({endpoint, uid, version}: { endpoint: string, uid: string, version: string }) {
    return endpoint + "?uid=" + uid + "&version=" + version;
  }

  static getAccountLinkRefreshUrl({hostname, uid, version}: { hostname: string, uid: string, version: string }): string {
    return this.getHttpPrefix({hostname: hostname}) + this.getHttpSuffix({endpoint: "stripeAccountLinkRefresh", uid: uid, version: version});
  }

  static getAccountLinkReturnUrl({hostname, uid, version}: { hostname: string, uid: string, version: string }): string {
    return this.getHttpPrefix({hostname: hostname}) + this.getHttpSuffix({endpoint: "stripeAccountLinkReturn", uid: uid, version: version});
  }

  static getAccountTokenSubmitUrl({hostname, uid, tokenInvalid, version}: { hostname: string, uid: string, tokenInvalid: boolean, version: string }): string {
    let url = this.getHttpPrefix({hostname: hostname}) + this.getHttpSuffix({endpoint: "stripeAccountTokenSubmit", uid: uid, version: version});
    if (tokenInvalid) {
      url += "&tokenInvalid=true";
    }
    return url;
  }
}
function isRunningInEmulator() {
  return process.env.FUNCTIONS_EMULATOR === "true";
}

