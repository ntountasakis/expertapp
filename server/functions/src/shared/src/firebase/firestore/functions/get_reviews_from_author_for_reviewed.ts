import {getReviewsCollectionRef} from "../document_fetchers/fetchers";

export function getReviewsFromAuthorForReviewed({authorUid, reviewedUid}: {authorUid: string, reviewedUid: string})
: FirebaseFirestore.Query<FirebaseFirestore.DocumentData> {
  const existingReviewsQuery = getReviewsCollectionRef()
      .where("authorUid", "==", authorUid)
      .where("reviewedUid", "==", reviewedUid);
  return existingReviewsQuery;
}
