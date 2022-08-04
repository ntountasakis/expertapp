import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";

export const userSignup = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const uid = context.auth.uid;
  const firstName : string = data.firstName;
  const lastName : string = data.lastName;
  const email : string = data.email;
  let profilePicUrl = "";
  if ("profilePicUrl" in data) {
    profilePicUrl = data.profilePicUrl;
  } else {
    const defaultProfilePicName = "Portrait_Placeholder.png";
    const pictureBucket = "gs://expert-app-backend.appspot.com/profilePics";
    const defaultPicFile = admin.storage()
        .bucket(pictureBucket)
        .file(defaultProfilePicName);

    profilePicUrl = defaultPicFile.publicUrl();
  }

  const batch = admin.firestore().batch();

  // eslint-disable-next-line max-len
  const stripe = new Stripe("sk_test_51LLQIdAoQ8pfRhfFWhXXPMmQkBMR1wAZSiFAc0fRZ3OQfnVJ3Mo5MXt65rv33lt0A7mzUIRWahIbSt2iFDFDrZ6C00jF2hT9eZ", {
    apiVersion: "2020-08-27",
  });

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

  const firebaseUser = {
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "stripeCustomerId": stripeCustomerId,
  };
  batch.set(admin.firestore().collection("users").doc(uid), firebaseUser);

  const firebaseUserMetadata = {
    "firstName": firstName,
    "lastName": lastName,
    "profilePicUrl": profilePicUrl,
    "runningSumReviewRatings": 0,
    "numReviews": 0,
  };

  batch.set(admin.firestore().collection("user_metadata").doc(uid),
      firebaseUserMetadata);

  await batch.commit();

  console.log(`User ${uid} signed up!`);
});
