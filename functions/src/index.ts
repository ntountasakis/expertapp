import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";

admin.initializeApp();

exports.userSignup = functions.https.onCall(async (data, context) => {
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

interface UserMetadata {
  firstName : string;
  lastName : string;
  profilePicUrl : string;
  runningSumReviewRatings : number;
  numReviews : number;
}

exports.submitReview = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const authorUid = context.auth.uid;
  const reviewedUid : string = data.reviewedUid;
  const reviewText : string = data.reviewText;
  const reviewRating : number = data.reviewRating;

  await admin.firestore().runTransaction(async (transaction) => {
    const userMetadataRef = admin.firestore().collection("user_metadata");
    const authorMetadataRef = await transaction.get(
        userMetadataRef.doc(authorUid));
    if (!authorMetadataRef.exists) {
      throw new Error(`No Author:${authorUid} in userMetadata collection`);
    }
    const reviewedMetadataRef = await transaction.get(
        userMetadataRef.doc(reviewedUid));
    if (!reviewedMetadataRef.exists) {
      throw new Error(`No Reviewed:${authorUid} in userMetadata collection`);
    }

    const authorMetadataObject = authorMetadataRef.data() as UserMetadata;
    const reviewedMetadataObject = reviewedMetadataRef.data() as UserMetadata;
    const review = {
      "authorUid": authorUid,
      "authorFirstName": authorMetadataObject.firstName,
      "authorLastName": authorMetadataObject.lastName,
      "reviewedUid": reviewedUid,
      "reviewText": reviewText,
      "rating": reviewRating,
    };

    const reviewRef = admin.firestore().collection("reviews").doc();
    transaction.create(reviewRef, review);

    reviewedMetadataObject.runningSumReviewRatings += reviewRating;
    reviewedMetadataObject.numReviews++;

    transaction.set(userMetadataRef.doc(reviewedUid), reviewedMetadataObject);

    console.log(`Review added by ${authorUid} for ${reviewedUid}`);
  });
});

exports.updateProfilePicture = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const profilePictureBucket = "gs://expert-app-backend.appspot.com/profilePics";
  const generatedImageName = uuidv4();
  const newPictureFile = admin.storage().bucket(profilePictureBucket)
      .file(generatedImageName);

  const pictureBytes : Buffer = Buffer.from(data.pictureBytes);
  await newPictureFile.save(pictureBytes);

  console.log(`Uploaded profilePic ${generatedImageName} 
    for user ${context.auth.uid}`);

  return newPictureFile.publicUrl;
});
