import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getDefaultProfilePicUrl} from "../../../shared/src/firebase/storage/functions/get_default_profile_pic_url";
import {StripeProvider} from "../../../shared/src/stripe/stripe_provider";
import {createStripeCustomer} from "../../../shared/src/stripe/util";
import {createExpertUser} from "../../../shared/src/firebase/firestore/functions/create_expert_user";

export const userSignup = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const uid = context.auth.uid;
  const firstName : string = data.firstName;
  const lastName : string = data.lastName;
  const email : string = data.email;

  const stripeCustomerId = await createStripeCustomer({stripe: StripeProvider.STRIPE});
  const profilePicUrl = "profilePicUrl" in data ? data.profilePicUrl : getDefaultProfilePicUrl();

  const batch = admin.firestore().batch();
  createExpertUser({batch: batch, uid: uid, firstName: firstName, lastName: lastName, email: email,
    stripeCustomerId: stripeCustomerId, profilePicUrl: profilePicUrl});
  await batch.commit();

  console.log(`User ${uid} signed up!`);
});
