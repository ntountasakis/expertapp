
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getExpertSignUpProgressDocumentRef, getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";

export const updateProfileDescription = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const uid = context.auth.uid;
  const description = data.description;
  const fromSignUpFlow = data.fromSignUpFlow;
  const version = data.version;

  if (uid == null || description == null || fromSignUpFlow == null || version == null) {
    throw new Error("Uid or description or fromSignUpFlow is null");
  }

  if (description.length < 30) {
    return {
      success: false,
      message: "Your profile description must be at least 30 characters long"
    };
  }
  const success = await admin.firestore().runTransaction(async (transaction) => {
    const publicExpertDocRef = getPublicExpertInfoDocumentRef({ uid: uid, fromSignUpFlow: fromSignUpFlow });
    const expertSignUpProgressDocRef = getExpertSignUpProgressDocumentRef({ uid: uid });
    const expertSignUpProgressDoc = fromSignUpFlow ? await transaction.get(expertSignUpProgressDocRef) : null;
    const publicExpertDoc = await transaction.get(publicExpertDocRef);
    if (!publicExpertDoc.exists) {
      Logger.logError({
        logName: "updateProfileDescription", message: `Failed to update description for ${uid} because they are not a expert. From sign up flow: ${fromSignUpFlow}`,
        labels: new Map([["expertId", uid], ["version", version]]),
      });
      return false;
    }
    if (fromSignUpFlow && !(expertSignUpProgressDoc!.exists)) {
      Logger.logError({
        logName: "updateProfileDescription", message: `Failed to update description for ${uid} because they have no expert sign up progress doc.`,
        labels: new Map([["expertId", uid], ["version", version]]),
      });
      return false;
    }
    if (fromSignUpFlow) {
      transaction.update(expertSignUpProgressDocRef, {
        "updatedProfileDescription": true,
      });
    }
    transaction.update(publicExpertDocRef, {
      "description": description,
    });
    Logger.log({
      logName: "updateProfileDescription", message: `Updated description for ${uid}. From sign up flow: ${fromSignUpFlow}`,
      labels: new Map([["expertId", uid], ["version", version]]),
    });
    return true;
  });

  return {
    success: success,
    message: success ? "Your profile description has been updated successfully" : "Internal Server Error",
  };
});
