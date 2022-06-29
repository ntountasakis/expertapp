import * as admin from "firebase-admin";

export async function lookupUserToken(userId: string): Promise<string> {
  const tokenCollection = admin.firestore().collection("fcm_tokens");
  const tokenDocument = await tokenCollection.doc(userId).get();
  if (!tokenDocument.exists) {
    console.error(`Cannot find token for user: ${userId}`);
    return "";
  }
  return tokenDocument.get("token");
}
