import { getUserMetadataDocumentRef } from "../document_fetchers/fetchers";
import { Review } from "../models/review";
import { UserMetadata } from "../models/user_metadata";
import {updateUserMetadataReviewAttributes} from "./update_user_metadata_review_attributes";

export function updateReview(
    {transaction, existingReviewDocumentReference, reviewedUserMetadata, reviewedUid, newReviewRating, newReviewText}:
    {transaction : FirebaseFirestore.Transaction,
        existingReviewDocumentReference: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>,
        reviewedUserMetadata: UserMetadata,
        reviewedUid: string, newReviewRating: number, newReviewText: string}): void {
  const existingReview = existingReviewDocumentReference.data() as Review;
  const thisReviewSumDifference = newReviewRating - existingReview.rating;
  const reviewedUserNewReviewSum = reviewedUserMetadata.runningSumReviewRatings + thisReviewSumDifference;

  transaction.update(existingReviewDocumentReference.ref, "reviewText", newReviewText);
  transaction.update(existingReviewDocumentReference.ref, "rating", newReviewRating);
  transaction.update(getUserMetadataDocumentRef({uid: reviewedUid}),
      "runningSumReviewRatings", reviewedUserNewReviewSum);
  updateUserMetadataReviewAttributes({transaction: transaction, reviewedUid: reviewedUid,
    runningSumReviewRatings: reviewedUserNewReviewSum, numReviews: reviewedUserMetadata.numReviews});
}
