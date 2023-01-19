import { getPublicExpertInfoDocumentRef } from "../document_fetchers/fetchers";
import { PublicExpertInfo } from "../models/public_expert_info";

export function createUserMetadata({ batch, uid, firstName, lastName, profilePicUrl }:
  {
    batch: FirebaseFirestore.WriteBatch, uid: string, firstName: string, lastName: string,
    profilePicUrl: string
  }): void {
  const firebaseUserMetadata: PublicExpertInfo = {
    "firstName": firstName,
    "lastName": lastName,
    "description": "",
    "profilePicUrl": profilePicUrl,
    "runningSumReviewRatings": 0,
    "numReviews": 0,
  };
  batch.set(getPublicExpertInfoDocumentRef({ uid: uid }), firebaseUserMetadata);
}
