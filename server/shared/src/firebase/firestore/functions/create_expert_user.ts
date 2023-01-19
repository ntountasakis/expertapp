import { getPrivateUserDocumentRef, getPublicExpertInfoDocumentRef } from "../document_fetchers/fetchers";
import { PrivateUserInfo } from "../models/private_user_info";
import { PublicExpertInfo } from "../models/public_expert_info";

export function createExpertUser({ batch, uid, firstName, lastName, email, profilePicUrl, stripeCustomerId }:
  {
    batch: FirebaseFirestore.WriteBatch, uid: string, firstName: string, lastName: string, email: string,
    profilePicUrl: string, stripeCustomerId: string
  }): void {
  const privateUserInfo: PrivateUserInfo = {
    "email": email,
    "stripeCustomerId": stripeCustomerId,
    "stripeConnectedId": ""
  };
  const publicExpertInfo: PublicExpertInfo = {
    "firstName": firstName,
    "lastName": lastName,
    "description": "",
    "profilePicUrl": profilePicUrl,
    "runningSumReviewRatings": 0,
    "numReviews": 0,
  };
  batch.set(getPrivateUserDocumentRef({ uid: uid }), privateUserInfo);
  batch.set(getPublicExpertInfoDocumentRef({ uid: uid }), publicExpertInfo);
}