
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getPublicExpertInfoDocumentRef} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";

export const updateProfileDescription = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const uid = context.auth.uid;
  const description = data.description;

  if (uid == null || description == null) {
    throw new Error("Uid or description is null");
  }
  await admin.firestore().runTransaction(async (transaction) => {
    transaction.update(getPublicExpertInfoDocumentRef({uid: uid}), {
      "description": description,
    });
  });
  console.log(`Updated description for ${uid}. New description: ${description}`);
});
