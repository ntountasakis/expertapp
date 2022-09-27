import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {UserMetadata} from "../firebase/firestore/models/user_metadata";
import {getUserMetadataDocumentRef} from "../firebase/firestore/document_fetchers/fetchers";
import {createReview} from "../firebase/firestore/functions/create_review";
import {updateReview} from "../firebase/firestore/functions/update_review";
import {getReviewsFromAuthorForReviewed} from "../firebase/firestore/functions/get_reviews_from_author_for_reviewed";

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
    const authorMetadata = await transaction.get(getUserMetadataDocumentRef({uid: authorUid}));
    if (!authorMetadata.exists) {
      throw new Error(`No Author:${authorUid} in userMetadata collection`);
    }
    const reviewedMetadata = await transaction.get(getUserMetadataDocumentRef({uid: reviewedUid}));
    if (!reviewedMetadata.exists) {
      throw new Error(`No Reviewed:${reviewedUid} in userMetadata collection`);
    }

    const matchingReviews = await transaction.get(
        getReviewsFromAuthorForReviewed({authorUid: authorUid, reviewedUid: reviewedUid}));
    if (matchingReviews.size > 1) {
      // eslint-disable-next-line max-len
      throw new Error(`Author ${authorUid} managed to leave ${matchingReviews.size} for ${reviewedUid}. Not leaving additional`);
    }
    const reviewedUserMetadataObject = reviewedMetadata.data() as UserMetadata;
    const authorUserMetadataObject = authorMetadata.data() as UserMetadata;
    if (matchingReviews.size == 1) {
      const rawReviewDoc= matchingReviews.docs.at(0);
      if (rawReviewDoc == null) {
        throw new Error(`Firestore DB error. 
            Review size 1 yet data is null`);
      }
      updateReview({transaction: transaction, existingReviewDocumentReference: rawReviewDoc,
        reviewedUserMetadata: reviewedUserMetadataObject, reviewedUid: reviewedUid, newReviewRating: reviewRating,
        newReviewText: reviewText});
      console.log(`Updated review by ${authorUid} for ${reviewedUid}`);
      return {
        message: "Review Updated",
      };
    }

    createReview({transaction: transaction, authorUid: authorUid, reviewedUid: reviewedUid,
      authorUserMetadata: authorUserMetadataObject,
      reviewedUserMetadata: reviewedUserMetadataObject,
      reviewText: reviewText, reviewRating: reviewRating});
    console.log(`Review added by ${authorUid} for ${reviewedUid}`);
    return {
      message: "Review Submitted",
    };
  });
});
