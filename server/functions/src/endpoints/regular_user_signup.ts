import * as functions from "firebase-functions";
import { StripeProvider } from "../../../shared/src/stripe/stripe_provider";
import { createStripeCustomer } from "../../../shared/src/stripe/util";
import { createRegularUser } from "../../../shared/src/firebase/firestore/functions/create_regular_user";
import configureStripeProviderForFunctions from "../stripe/stripe_provider_functions_configurer";

export const regularUserSignup = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const uid = context.auth.uid;
  const email: string = data.email;
  const firstName: string = data.firstName;
  const lastName: string = data.lastName;


  await configureStripeProviderForFunctions();
  const stripeCustomerId = await createStripeCustomer({ stripe: StripeProvider.STRIPE });
  await createRegularUser({
    uid: uid, email: email, stripeCustomerId: stripeCustomerId,
    firstName: firstName, lastName: lastName
  });

  console.log(`User ${uid} signed up!`);
});
