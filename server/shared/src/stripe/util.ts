import Stripe from "stripe";

async function createStripeCustomer({stripe}: {stripe: Stripe}) : Promise<string> {
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

async function createStripeConnectAccount({stripe, firstName, lastName, email}:
    {stripe: Stripe, firstName: string, lastName: string, email: string}): Promise<string> {
  const account: Stripe.Response<Stripe.Account> = await stripe.accounts.create({
    type: "express",
    business_type: "individual",
    capabilities: {
      card_payments: {requested: true},
      transfers: {requested: true},
    },
    individual: {
      email: email,
      first_name: firstName,
      last_name: lastName,
    },
  });
  return account.id;
}

export async function createAccountLinkOnboarding({stripe, account, refreshUrl, returnUrl}:
    {stripe: Stripe, account: string, refreshUrl: string, returnUrl: string}): Promise<string> {
  const accountLink = await stripe.accountLinks.create(
      {
        account: account,
        refresh_url: refreshUrl,
        return_url: returnUrl,
        type: "account_onboarding",
      },
  );

  return accountLink.url;
}

async function retrieveAccount({stripe, account}: {stripe: Stripe, account: string}):
Promise<Stripe.Response<Stripe.Account>> {
  return await stripe.accounts.retrieve(account);
}

export {createStripeConnectAccount, createStripeCustomer, retrieveAccount};
