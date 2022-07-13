import * as admin from "firebase-admin";

export async function lookupUserFcmToken(
    {userId, transaction}: {userId: string, transaction: FirebaseFirestore.Transaction}):
    Promise<[success: boolean, errorMessage: string, token: string]> {
  const tokenCollection = admin.firestore().collection("fcm_tokens");
  const tokenDocument = await transaction.get(tokenCollection.doc(userId));
  if (!tokenDocument.exists) {
    return [false, `Cannot find token for user: ${userId}`, ""];
  }
  return [true, "", tokenDocument.get("token")];
}
