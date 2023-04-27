import * as admin from "firebase-admin";
import {getPrivateUserDocumentRef, getPublicUserDocumentRef} from "../document_fetchers/fetchers";
import {PrivateUserInfo} from "../models/private_user_info";
import {PublicUserInfo} from "../models/public_user_info";

export async function createRegularUser({uid, email, stripeCustomerId, firstName, lastName}:
    {
        uid: string, email: string, stripeCustomerId: string, firstName: string, lastName: string,
    }): Promise<void> {
  const privateUserInfo: PrivateUserInfo = {
    "email": email,
    "stripeCustomerId": stripeCustomerId,
    "stripeConnectedId": "",
  };
  const publicUserInfo: PublicUserInfo = {
    "firstName": firstName,
    "lastName": lastName,
  };
  await admin.firestore().runTransaction(async (transaction) => {
    transaction.set(getPrivateUserDocumentRef({uid: uid}), privateUserInfo);
    transaction.set(getPublicUserDocumentRef({uid: uid}), publicUserInfo);
  });
}
