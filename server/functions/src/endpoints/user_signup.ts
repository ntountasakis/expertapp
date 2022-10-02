import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {createStripeCustomer} from "../cloud_functions/stripe/util";
import {createUser} from "../firebase/firestore/functions/create_user";
import {createUserMetadata} from "../firebase/firestore/functions/create_user_metadata";
import {getDefaultProfilePicUrl} from "../firebase/storage/functions/get_default_profile_pic_url";
import {StripeProvider} from "../../../shared/stripe/stripe_provider";

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
  createUser({batch: batch, uid: uid, firstName: firstName, lastName: lastName, email: email,
    stripeCustomerId: stripeCustomerId});
  createUserMetadata({batch: batch, uid: uid, firstName: firstName, lastName: lastName, profilePicUrl: profilePicUrl});
  await batch.commit();

  console.log(`User ${uid} signed up!`);
});
