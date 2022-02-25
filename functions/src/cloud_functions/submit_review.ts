import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {UserMetadata} from "../models/user_metadata";
import {Review} from "../models/review";

export const submitReview = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const authorUid = context.auth.uid;
  const reviewedUid : string = data.reviewedUid;
  const reviewText : string = data.reviewText;
  const reviewRating : number = data.reviewRating;

  const responseData = await admin.firestore()
      .runTransaction(async (transaction) => {
        if (authorUid == reviewedUid) {
          throw new Error(`Attempt to leave review for onself. 
            Uid: ${authorUid}`);
        }

        const userMetadataCollectionRef = admin.firestore()
            .collection("user_metadata");
        const authorMetadataDoc = await transaction.get(
            userMetadataCollectionRef.doc(authorUid));
        if (!authorMetadataDoc.exists) {
          throw new Error(`No Author:${authorUid} in userMetadata collection`);
        }
        const reviewedMetadataDoc = await transaction.get(
            userMetadataCollectionRef.doc(reviewedUid));
        if (!reviewedMetadataDoc.exists) {
          throw new Error(`No Reviewed:${authorUid} 
            in userMetadata collection`);
        }

        const reviewsCollectionRef = admin.firestore().collection("reviews");
        const reviewedMetadataObject =
          reviewedMetadataDoc.data() as UserMetadata;

        const existingReviewsQuery = reviewsCollectionRef
            .where("authorUid", "==", authorUid)
            .where("reviewedUid", "==", reviewedUid);

        const matchingReviews = await transaction.get(existingReviewsQuery);

        if (matchingReviews.size > 1) {
          throw new Error(`Author ${authorUid} managed to leave 
        ${matchingReviews.size} for ${reviewedUid}. Not leaving additional`);
        } else if (matchingReviews.size == 1) {
          const rawReviewDoc= matchingReviews.docs.at(0);
          if (rawReviewDoc == null) {
            throw new Error(`Firestore DB error. 
              Review size 1 yet data is null`);
          }
          const existingReview = rawReviewDoc.data() as Review;
          const thisReviewSumDifference = reviewRating - existingReview.rating;
          const reviewedUserNewReviewSum =
        reviewedMetadataObject.runningSumReviewRatings +
        thisReviewSumDifference;

          transaction.update(rawReviewDoc.ref, "reviewText", reviewText);
          transaction.update(rawReviewDoc.ref, "rating", reviewRating);
          transaction.update(reviewedMetadataDoc.ref, "runningSumReviewRatings",
              reviewedUserNewReviewSum);

          console.log(`Updated review by ${authorUid} for ${reviewedUid}`);
          return {
            message: "Review Updated",
          };
        }

        const authorMetadataObject = authorMetadataDoc.data() as UserMetadata;

        const review = {
          "authorUid": authorUid,
          "authorFirstName": authorMetadataObject.firstName,
          "authorLastName": authorMetadataObject.lastName,
          "reviewedUid": reviewedUid,
          "reviewText": reviewText,
          "rating": reviewRating,
        };

        transaction.create(reviewsCollectionRef.doc(), review);

        reviewedMetadataObject.runningSumReviewRatings += reviewRating;
        reviewedMetadataObject.numReviews++;

        transaction.set(reviewedMetadataDoc.ref, reviewedMetadataObject);

        console.log(`Review added by ${authorUid} for ${reviewedUid}`);
        return {
          message: "Review Submitted",
        };
      });
  return responseData;
});
