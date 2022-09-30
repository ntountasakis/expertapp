import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";
import {createStripeCustomer} from "../cloud_functions/stripe/util";
import {createUser} from "../firebase/firestore/functions/create_user";
import {createUserMetadata} from "../firebase/firestore/functions/create_user_metadata";
import {getDefaultProfilePicUrl} from "../firebase/storage/functions/get_default_profile_pic_url";

export const userSignup = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const uid = context.auth.uid;
  const firstName : string = data.firstName;
  const lastName : string = data.lastName;
  const email : string = data.email;


  const stripe = new Stripe("sk_test_51LLQIdAoQ8pfRhfFWhXXPMmQkBMR1wAZSiFAc0fRZ3OQfnVJ3Mo5MXt65rv33lt0A7mzUIRWahIbSt2iFDFDrZ6C00jF2hT9eZ", {
    apiVersion: "2022-08-01",
  });

  const stripeCustomerId = await createStripeCustomer({stripe: stripe});
  const profilePicUrl = "profilePicUrl" in data ? data.profilePicUrl : getDefaultProfilePicUrl();

  const batch = admin.firestore().batch();
  createUser({batch: batch, uid: uid, firstName: firstName, lastName: lastName, email: email,
    stripeCustomerId: stripeCustomerId});
  createUserMetadata({batch: batch, uid: uid, firstName: firstName, lastName: lastName, profilePicUrl: profilePicUrl});
  await batch.commit();

  console.log(`User ${uid} signed up!`);
});
