import { getFcmTokenDocumentRef } from "../../../../../../shared/firebase/firestore/document_fetchers/fetchers";

export async function lookupUserFcmToken(
    {userId, transaction}: {userId: string, transaction: FirebaseFirestore.Transaction}):
    Promise<[success: boolean, errorMessage: string, token: string]> {
  const tokenDocument = await transaction.get(getFcmTokenDocumentRef({uid: userId}));
  if (!tokenDocument.exists) {
    return [false, `Cannot find token for user: ${userId}`, ""];
  }
  return [true, "", tokenDocument.get("token")];
}
