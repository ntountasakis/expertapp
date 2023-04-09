
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";

export const updateProfileDescription = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const uid = context.auth.uid;
  const description = data.description;

  if (uid == null || description == null) {
    throw new Error("Uid or description is null");
  }

  if (description.length < 30) {
    return {
      success: false,
      message: "Your profile description must be at least 30 characters long"
    };
  }
  const success = await admin.firestore().runTransaction(async (transaction) => {
    const publicExpertDoc = await transaction.get(getPublicExpertInfoDocumentRef({ uid: uid }));
    if (!publicExpertDoc.exists) {
      Logger.logError({
        logName: "updateProfileDescription", message: `Failed to update description for ${uid} because they are not a expert.`,
        labels: new Map([["expertId", uid]]),
      });
      return false;
    }
    transaction.update(getPublicExpertInfoDocumentRef({ uid: uid }), {
      "description": description,
    });
    Logger.log({
      logName: "updateProfileDescription", message: `Updated description for ${uid}. New description: ${description}`,
      labels: new Map([["expertId", uid]]),
    });
    return true;
  });

  return {
    success: success,
    message: success ? "Your profile description has been updated successfully" : "Internal Server Error",
  };
});
