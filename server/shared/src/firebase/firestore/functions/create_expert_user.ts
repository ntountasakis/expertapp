import * as admin from "firebase-admin";
import { getPrivateUserDocumentRef, getPublicExpertInfoDocumentRef } from "../document_fetchers/fetchers";
import { PrivateUserInfo } from "../models/private_user_info";
import { PublicExpertInfo } from "../models/public_expert_info";

export async function createExpertUser({ uid, firstName, lastName, email, profilePicUrl, stripeCustomerId }:
  {
    uid: string, firstName: string, lastName: string, email: string,
    profilePicUrl: string, stripeCustomerId: string
  }): Promise<void> {
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
  await admin.firestore().runTransaction(async (transaction) => {
    transaction.set(getPrivateUserDocumentRef({ uid: uid }), privateUserInfo);
    transaction.set(getPublicExpertInfoDocumentRef({ uid: uid }), publicExpertInfo);
  });
}