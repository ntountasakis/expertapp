import { getPublicExpertInfoDocumentRef } from "../document_fetchers/fetchers";

export function updateUserMetadataReviewAttributes(
    { transaction, reviewedUid, runningSumReviewRatings, numReviews }:
        {
            transaction: FirebaseFirestore.Transaction,
            reviewedUid: string,
            runningSumReviewRatings: number,
            numReviews: number
        }): void {
    const reviewedUserMetadataRef = getPublicExpertInfoDocumentRef({ uid: reviewedUid });
    transaction.update(reviewedUserMetadataRef,
        "runningSumReviewRatings", runningSumReviewRatings);
    transaction.update(reviewedUserMetadataRef,
        "numReviews", numReviews);
}
