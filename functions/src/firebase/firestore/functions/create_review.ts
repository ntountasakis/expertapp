import {getReviewsCollectionRef} from "../document_fetchers/fetchers";
import {Review} from "../models/review";
import {UserMetadata} from "../models/user_metadata";
import {updateUserMetadataReviewAttributes} from "./update_user_metadata_review_attributes";

export function createReview({transaction, authorUid, reviewedUid,
  authorUserMetadata, reviewedUserMetadata, reviewText, reviewRating}:
    {transaction: FirebaseFirestore.Transaction, authorUid: string, reviewedUid: string,
    authorUserMetadata: UserMetadata, reviewedUserMetadata: UserMetadata,
    reviewText: string, reviewRating: number}): void {
  const review: Review = {
    "authorUid": authorUid,
    "authorFirstName": authorUserMetadata.firstName,
    "authorLastName": authorUserMetadata.lastName,
    "reviewedUid": reviewedUid,
    "reviewText": reviewText,
    "rating": reviewRating,
  };
  transaction.create(getReviewsCollectionRef().doc(), review);

  updateUserMetadataReviewAttributes({transaction: transaction, reviewedUid: reviewedUid,
    runningSumReviewRatings: reviewedUserMetadata.runningSumReviewRatings + review.rating,
    numReviews: reviewedUserMetadata.numReviews + 1});
}
