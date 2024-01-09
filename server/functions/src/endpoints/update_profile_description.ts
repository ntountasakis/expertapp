import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getExpertInfoConditionalOnSignup, FirebaseDocRef} from "../shared/src/firebase/firestore/functions/expert_info_conditional_sign_up_fetcher";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";

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
      message: "Your profile description must be at least 30 characters long",
    };
  }
  const success = await admin.firestore().runTransaction(async (transaction) => {
    const wasSuccess: boolean = await getExpertInfoConditionalOnSignup({functionNameForLogging: "updateProfileDescription",
      uid: uid, fromSignUpFlow: fromSignUpFlow,
      transaction: transaction, version: version, updateSignupProgressFunc: updateSignupProgress,
      updateExpertInfoFunc: updateExpertInfo,
      contextData: description,
    });
    if (wasSuccess) {
      Logger.log({
        logName: "updateProfileDescription", message: `Updated description for ${uid}. From sign up flow: ${fromSignUpFlow}`,
        labels: new Map([["expertId", uid], ["version", version]]),
      });
    }
    return wasSuccess;
  });

  return {
    success: success,
    message: success ? "Your profile description has been updated successfully" : "Internal Server Error",
  };
});

function updateSignupProgress(signupProgressDocRef: FirebaseDocRef, transaction: FirebaseFirestore.Transaction) {
  if (signupProgressDocRef == null) {
    throw new Error("Cannot update signup progress for updateProfileDescription because signup progress doc ref is null");
  }
  transaction.update(signupProgressDocRef, {
    "updatedProfileDescription": true,
  });
}

function updateExpertInfo(expertInfoRef: FirebaseDocRef, transaction: FirebaseFirestore.Transaction, updatedDescription: string) {
  if (expertInfoRef == null) {
    throw new Error("Cannot update expert category for updateProfileDescription because expert info doc ref is null");
  }
  transaction.update(expertInfoRef, {
    "description": updatedDescription,
  });
}
