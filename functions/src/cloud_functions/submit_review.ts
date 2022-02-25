import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {UserMetadata} from "../models/user_metadata";

export const submitReview = functions.https.onCall(async (data, context) => {
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
