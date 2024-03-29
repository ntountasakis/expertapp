import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getPublicExpertInfoDocumentRef, getExpertSignUpProgressDocumentRef} from "../shared/src/firebase/firestore/document_fetchers/fetchers";
import {isExpertSignupProgressComplete, ExpertSignupProgress} from "../shared/src/firebase/firestore/models/expert_signup_progress";
import {PublicExpertInfo} from "../shared/src/firebase/firestore/models/public_expert_info";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";

export const completeExpertSignUp = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const uid = context.auth.uid;
  const version = data.version;

  try {
    const success = await admin.firestore().runTransaction(async (transaction) => {
      const stagingPublicExpertDoc = await transaction.get(getPublicExpertInfoDocumentRef({uid: uid, fromSignUpFlow: true}));
      if (!stagingPublicExpertDoc.exists) {
        Logger.logError({
          logName: "completeExpertSignUp", message: `Cannot complete expert sign up for ${uid} because they have no staging doc`,
          labels: new Map([["expertId", uid], ["version", version]]),
        });
        return false;
      }
      const expertSignupProgressDoc = await transaction.get(getExpertSignUpProgressDocumentRef({uid: uid}));
      if (!expertSignupProgressDoc.exists) {
        Logger.logError({
          logName: "completeExpertSignUp", message: `Cannot complete expert sign up for ${uid} because they have no expert signup progress doc`,
          labels: new Map([["expertId", uid], ["version", version]]),
        });
        return false;
      }
      if (!isExpertSignupProgressComplete(expertSignupProgressDoc.data() as ExpertSignupProgress)) {
        Logger.logError({
          logName: "completeExpertSignUp", message: `Cannot complete expert sign up for ${uid} \
                    because their expert signup progress doc is not complete: \
                    ${JSON.stringify(expertSignupProgressDoc.data())}`,
          labels: new Map([["expertId", uid], ["version", version]]),
        });
        return false;
      }

      const finalPublicExpertRef = getPublicExpertInfoDocumentRef({uid: uid, fromSignUpFlow: false});

      transaction.set(finalPublicExpertRef, stagingPublicExpertDoc.data() as PublicExpertInfo);
      transaction.delete(stagingPublicExpertDoc.ref);
      transaction.delete(getExpertSignUpProgressDocumentRef({uid: uid}));
      Logger.log({
        logName: "completeExpertSignUp", message: `Completed expert sign up for ${uid}`,
        labels: new Map([["expertId", uid], ["version", version]]),
      });
      return true;
    });
    return {
      success: success,
      message: success ? "You have successfully signed up" : "Internal Server Error",
    };
  } catch (e) {
    Logger.logError({
      logName: "completeExpertSignUp", message: `Failed to complete expert sign up for ${uid} because of error: ${e}`,
      labels: new Map([["expertId", uid], ["version", version]]),
    });
    return {
      success: false,
      message: "Internal Server Error",
    };
  }
});
