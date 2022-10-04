import {getUserDocumentRef} from "../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {User} from "../../../../../shared/firebase/firestore/models/user";
export function createUser({batch, uid, firstName, lastName, email, stripeCustomerId}:
    {batch : FirebaseFirestore.WriteBatch, uid: string, firstName: string, lastName: string, email: string,
        stripeCustomerId: string}): void {
  const firebaseUser: User = {
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "stripeCustomerId": stripeCustomerId,
  };
  batch.set(getUserDocumentRef({uid: uid}), firebaseUser);
}
