import * as functions from "firebase-functions";
import {StripeProvider} from "../../../shared/src/stripe/stripe_provider";

export default async function configureStripeProviderForFunctions(): Promise<void> {
  return StripeProvider.configureStripe(functions.config().envs["stripe_private_key_version"]);
}
