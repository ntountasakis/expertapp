import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const userSignup = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const uid = context.auth.uid;
  const firstName : string = data.firstName;
  const lastName : string = data.lastName;
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

  const firebaseUser = {
    "firstName": firstName,
    "lastName": lastName,
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