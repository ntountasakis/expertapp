import { getPublicExpertInfoDocumentRef } from "../document_fetchers/fetchers";
import { Review } from "../models/review";
import { PublicExpertInfo } from "../models/public_expert_info";
import { updateUserMetadataReviewAttributes } from "./update_user_metadata_review_attributes";

export function updateReview(
    { transaction, existingReviewDocumentReference, reviewedUserMetadata, reviewedUid, newReviewRating, newReviewText }:
        {
            transaction: FirebaseFirestore.Transaction,
            existingReviewDocumentReference: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>,
            reviewedUserMetadata: PublicExpertInfo,
            reviewedUid: string, newReviewRating: number, newReviewText: string
        }): void {
    const existingReview = existingReviewDocumentReference.data() as Review;
    const thisReviewSumDifference = newReviewRating - existingReview.rating;
    const reviewedUserNewReviewSum = reviewedUserMetadata.runningSumReviewRatings + thisReviewSumDifference;

    transaction.update(existingReviewDocumentReference.ref, "reviewText", newReviewText);
    transaction.update(existingReviewDocumentReference.ref, "rating", newReviewRating);
    transaction.update(getPublicExpertInfoDocumentRef({ uid: reviewedUid, fromSignUpFlow: false }),
        "runningSumReviewRatings", reviewedUserNewReviewSum);
    updateUserMetadataReviewAttributes({
        transaction: transaction, reviewedUid: reviewedUid,
        runningSumReviewRatings: reviewedUserNewReviewSum, numReviews: reviewedUserMetadata.numReviews
    });
}
