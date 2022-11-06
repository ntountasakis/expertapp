import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getUserMetadataDocument} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {createReview} from "../../../shared/src/firebase/firestore/functions/create_review";
import {getReviewsFromAuthorForReviewed} from "../../../shared/src/firebase/firestore/functions/get_reviews_from_author_for_reviewed";
import {updateReview} from "../../../shared/src/firebase/firestore/functions/update_review";
import {UserMetadata} from "../../../shared/src/firebase/firestore/models/user_metadata";

export const submitReview = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const authorUid = context.auth.uid;
  const reviewedUid : string = data.reviewedUid;
  const reviewText : string = data.reviewText;
  const reviewRating : number = data.reviewRating;

  if (authorUid == null || reviewedUid == null || reviewText == null) {
    throw new Error("Cannot leave review, some review attributes null");
  }

  if (authorUid == reviewedUid) {
    throw new Error(`Attempt to leave review for onself.  Uid: ${authorUid}`);
  }

  return await admin.firestore().runTransaction(async (transaction) => {
    const authorUserMetadata: UserMetadata = await getUserMetadataDocument(
        {transaction: transaction, uid: authorUid});
    const reviewedUserMetadata: UserMetadata = await getUserMetadataDocument(
        {transaction: transaction, uid: reviewedUid});

    const matchingReviews = await transaction.get(
        getReviewsFromAuthorForReviewed({authorUid: authorUid, reviewedUid: reviewedUid}));
    if (matchingReviews.size > 1) {
      throw new Error(`Author ${authorUid} managed to leave ${matchingReviews.size} for ${reviewedUid}. 
      Not leaving additional`);
    }
    if (matchingReviews.size == 1) {
      const rawReviewDoc= matchingReviews.docs.at(0);
      if (rawReviewDoc == null) {
        throw new Error(`Firestore DB error. 
            Review size 1 yet data is null`);
      }
      updateReview({transaction: transaction, existingReviewDocumentReference: rawReviewDoc,
        reviewedUserMetadata: reviewedUserMetadata, reviewedUid: reviewedUid, newReviewRating: reviewRating,
        newReviewText: reviewText});
      console.log(`Updated review by ${authorUid} for ${reviewedUid}`);
      return {
        message: "Review Updated",
      };
    }

    createReview({transaction: transaction, authorUid: authorUid, reviewedUid: reviewedUid,
      authorUserMetadata: authorUserMetadata,
      reviewedUserMetadata: reviewedUserMetadata,
      reviewText: reviewText, reviewRating: reviewRating});
    console.log(`Review added by ${authorUid} for ${reviewedUid}`);
    return {
      message: "Review Submitted",
    };
  });
});
