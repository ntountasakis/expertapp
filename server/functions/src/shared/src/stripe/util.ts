import Stripe from "stripe";
import {Logger} from "../google_cloud/google_cloud_logger";
import handleStripeError from "./stripe_error_handler";

async function createStripeCustomer({stripe, firstName, lastName, email}:
  { stripe: Stripe, firstName: string, lastName: string, email: string }): Promise<string> {
  let stripeCustomerId = "";
  let errorMessage = "Cannot create Stripe customer. ";
  try {
    const stripeCustomerResponse = await stripe.customers.create({
      name: firstName + " " + lastName,
      email: email,
    });
    stripeCustomerId = stripeCustomerResponse.id;
  } catch (error) {
    errorMessage += handleStripeError("createStripeCustomer", error);
    throw new Error(errorMessage);
  }
  return stripeCustomerId;
}


async function deleteStripeCustomer({stripe, customerId}:
  { stripe: Stripe, customerId: string }): Promise<void> {
  let errorMessage = "Cannot delete Stripe customer. " + customerId;
  try {
    await stripe.customers.del(customerId);
  } catch (error) {
    errorMessage += handleStripeError("deleteStripeCustomer", error);
    throw new Error(errorMessage);
  }
}

async function deleteStripeConnectedAccount({stripe, connectedAccountId}:
  { stripe: Stripe, connectedAccountId: string }): Promise<void> {
  let errorMessage = "Cannot delete Stripe connected account. " + connectedAccountId;
  try {
    const result = await stripe.accounts.del(connectedAccountId);
    if (!result.deleted) {
      throw new Error(errorMessage);
    }
  } catch (error) {
    errorMessage += handleStripeError("deleteStripeConnectedAccount", error);
    throw new Error(errorMessage);
  }
}

async function createStripeConnectAccount({stripe, firstName, lastName, email}:
  { stripe: Stripe, firstName: string, lastName: string, email: string }): Promise<string> {
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

export async function createAccountLinkOnboarding({stripe, stripeConnectedId, refreshUrl, returnUrl, functionContext, expertUid}:
  { stripe: Stripe, stripeConnectedId: string, refreshUrl: string, returnUrl: string, functionContext: string, expertUid: string }): Promise<string> {
  const accountLink = await stripe.accountLinks.create(
      {
        account: stripeConnectedId,
        refresh_url: refreshUrl,
        return_url: returnUrl,
        type: "account_onboarding",
      },
  );
  Logger.log({
    logName: functionContext, message: `Created account link for account ${stripeConnectedId}: refresh_url: ${refreshUrl}, return_url: ${returnUrl}`,
    labels: new Map([["expertId", expertUid]]),
  });

  return accountLink.url;
}

async function retrieveAccount({stripe, account}: { stripe: Stripe, account: string }):
  Promise<Stripe.Response<Stripe.Account>> {
  return await stripe.accounts.retrieve(account);
}

export {createStripeConnectAccount, createStripeCustomer, retrieveAccount, deleteStripeCustomer, deleteStripeConnectedAccount};
