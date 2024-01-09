import * as functions from "firebase-functions";
import {StripeProvider} from "../shared/src/stripe/stripe_provider";

export const getPlatformFee = functions.https.onCall(async (_data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  return {
    platformPercentFee: StripeProvider.PLATFORM_PERCENT_FEE,
  };
});
