import handleStripeError from "./stripe_error_handler";
import {StripeProvider} from "./stripe_provider";

export default async function createConnectedAccountDashboardLoginLink({connectedAccountId}: { connectedAccountId: string }): Promise<string> {
  let errorMessage = "Stripe login link url failure for connected account id: " + connectedAccountId + " ";
  try {
    const loginLink = await StripeProvider.STRIPE.accounts.createLoginLink(connectedAccountId, {apiVersion: StripeProvider.API_VERSION});
    if (!loginLink.url) {
      errorMessage += "url is null";
      throw new Error(errorMessage);
    }
    return loginLink.url;
  } catch (error) {
    errorMessage += handleStripeError("createConnectedAccountDashboardLoginLink", error);
    throw new Error(errorMessage);
  }
}
