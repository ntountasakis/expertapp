import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getPublicExpertInfo } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { createReview } from "../../../shared/src/firebase/firestore/functions/create_review";
import { getReviewsFromAuthorForReviewed } from "../../../shared/src/firebase/firestore/functions/get_reviews_from_author_for_reviewed";
import { updateReview } from "../../../shared/src/firebase/firestore/functions/update_review";
import { PublicExpertInfo } from "../../../shared/src/firebase/firestore/models/public_expert_info";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";

export const submitReview = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const authorUid = context.auth.uid;
  const reviewedUid: string = data.reviewedUid;
  const reviewText: string = data.reviewText;
  const reviewRating: number = data.reviewRating;

  if (authorUid == null || reviewedUid == null || reviewText == null) {
    throw new Error("Cannot leave review, some review attributes null");
  }

  if (authorUid == reviewedUid) {
    throw new Error(`Attempt to leave review for onself.  Uid: ${authorUid}`);
  }

  return await admin.firestore().runTransaction(async (transaction) => {
    const authorUserMetadata: PublicExpertInfo = await getPublicExpertInfo(
      { transaction: transaction, uid: authorUid });
    const reviewedUserMetadata: PublicExpertInfo = await getPublicExpertInfo(
      { transaction: transaction, uid: reviewedUid });

    const matchingReviews = await transaction.get(
      getReviewsFromAuthorForReviewed({ authorUid: authorUid, reviewedUid: reviewedUid }));
    if (matchingReviews.size > 1) {
      throw new Error(`Author ${authorUid} managed to leave ${matchingReviews.size} for ${reviewedUid}. 
      Not leaving additional`);
    }
    if (matchingReviews.size == 1) {
      const rawReviewDoc = matchingReviews.docs.at(0);
      if (rawReviewDoc == null) {
        throw new Error(`Firestore DB error. 
            Review size 1 yet data is null`);
      }
      updateReview({
        transaction: transaction, existingReviewDocumentReference: rawReviewDoc,
        reviewedUserMetadata: reviewedUserMetadata, reviewedUid: reviewedUid, newReviewRating: reviewRating,
        newReviewText: reviewText
      });
      Logger.log({
        logName: "submitReview", message: `Updated review by ${authorUid} for ${reviewedUid}`,
        labels: new Map([["userId", authorUid], ["expertId", reviewedUid]]),
      });
      return {
        message: "Review Updated",
      };
    }

    createReview({
      transaction: transaction, authorUid: authorUid, reviewedUid: reviewedUid,
      authorUserMetadata: authorUserMetadata,
      reviewedUserMetadata: reviewedUserMetadata,
      reviewText: reviewText, reviewRating: reviewRating
    });
    Logger.log({
      logName: "submitReview", message: `Review added by ${authorUid} for ${reviewedUid}`,
      labels: new Map([["userId", authorUid], ["expertId", reviewedUid]]),
    });
    return {
      message: "Review Submitted",
    };
  });
});
