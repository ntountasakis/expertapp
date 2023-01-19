import { getUserMetadataDocumentRef } from "../document_fetchers/fetchers";
import { UserMetadata } from "../models/user_metadata";

export function createUserMetadata({ batch, uid, firstName, lastName, profilePicUrl }:
  {
    batch: FirebaseFirestore.WriteBatch, uid: string, firstName: string, lastName: string,
    profilePicUrl: string
  }): void {
  const firebaseUserMetadata: UserMetadata = {
    "firstName": firstName,
    "lastName": lastName,
    "description": "",
    "profilePicUrl": profilePicUrl,
    "runningSumReviewRatings": 0,
    "numReviews": 0,
  };
  batch.set(getUserMetadataDocumentRef({ uid: uid }), firebaseUserMetadata);
}
