import { getUserDocumentRef } from "../document_fetchers/fetchers";
import { PrivateUserInfo } from "../models/private_user_info";

export function createUser({ batch, uid, firstName, lastName, email, stripeCustomerId }:
  {
    batch: FirebaseFirestore.WriteBatch, uid: string, firstName: string, lastName: string, email: string,
    stripeCustomerId: string
  }): void {
  const firebaseUser: PrivateUserInfo = {
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "stripeCustomerId": stripeCustomerId,
    "stripeConnectedId": ""
  };
  batch.set(getUserDocumentRef({ uid: uid }), firebaseUser);
}