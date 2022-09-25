import Stripe from "stripe";

export async function createStripeUser({stripe}: {stripe: Stripe}) : Promise<string> {
  let stripeCustomerId = "";
  try {
    const stripeCustomerResponse = await stripe.customers.create();
    stripeCustomerId = stripeCustomerResponse.id;
  } catch (error) {
    if (error instanceof stripe.errors.StripeAPIError) {
      throw new Error(`Cannot create Stripe customer. Api Error: ${error.message}`);
    } else if (error instanceof stripe.errors.StripeInvalidRequestError) {
      throw new Error(`Cannot create Stripe customer.  Invalid Request Error: ${error.message}`);
    } else {
      throw new Error(`Cannot create Stripe customer.  Unknown Error: ${error}`);
    }
  }
  return stripeCustomerId;
}
