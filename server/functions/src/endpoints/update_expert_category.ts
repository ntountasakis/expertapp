import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getExpertCategoryRef} from "../shared/src/firebase/firestore/document_fetchers/fetchers";
import {getExpertInfoConditionalOnSignup, FirebaseDocRef} from "../shared/src/firebase/firestore/functions/expert_info_conditional_sign_up_fetcher";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";

export const updateExpertCategory = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const uid = context.auth.uid;
  const newMajorCategory: string = data.newMajorCategory;
  const newMinorCategory: string = data.newMinorCategory;
  const fromSignUpFlow: boolean = data.fromSignUpFlow;
  const version: string = data.version;

  try {
    if (uid == null || newMajorCategory == null || newMinorCategory == null || fromSignUpFlow == null) {
      throw new Error("Cannot update expert category, some attributes null");
    }

    const success = await admin.firestore().runTransaction(async (transaction) => {
      const expertCategoryDoc = await transaction.get(getExpertCategoryRef({majorCategory: newMajorCategory}));
      if (!expertCategoryDoc.exists) {
        Logger.logError({
          logName: "updateExpertCategory", message: `Cannot update expert category for ${uid} \
          because major category ${newMajorCategory} does not exist`,
          labels: new Map([["expertId", uid], ["version", version]]),
        });
        return false;
      }
      // eslint-disable-next-line @typescript-eslint/ban-types
      const categoryTypes: Array<string> = Object.keys(expertCategoryDoc.data() as Object);
      if (!categoryTypes.includes(newMinorCategory)) {
        Logger.logError({
          logName: "updateExpertCategory", message: `Cannot update expert category for ${uid} \
          because minor category ${newMinorCategory} does not exist`,
          labels: new Map([["expertId", uid], ["version", version]]),
        });
        return false;
      }

      const updatedCategories: [string, string] = [newMajorCategory, newMinorCategory];
      const wasSuccess: boolean = await getExpertInfoConditionalOnSignup({functionNameForLogging: "updateExpertCategory",
        uid: uid, fromSignUpFlow: fromSignUpFlow,
        transaction: transaction, version: version, updateSignupProgressFunc: updateSignupProgress,
        updateExpertInfoFunc: updateExpertInfo,
        contextData: updatedCategories,
      });
      if (wasSuccess) {
        Logger.log({
          logName: "updateExpertCategory", message: `Updated expert category for ${uid}. \
          New major category: ${newMajorCategory} new minor category: ${newMinorCategory} From sign up flow: ${fromSignUpFlow}`,
          labels: new Map([["expertId", uid], ["version", version]]),
        });
      }
      return wasSuccess;
    });
    return {
      success: success,
      message: success ? "Your categories have been updated successfully" : "Internal Server Error",
    };
  } catch (e) {
    Logger.logError({
      logName: "updateExpertCategory", message: `Failed to update expert category for ${uid}. From sign up flow ${fromSignUpFlow} Error: ${e}`,
      labels: new Map([["expertId", uid], ["version", version]]),
    });
    return {
      success: false,
      message: "Internal Server Error",
    };
  }
});

function updateSignupProgress(signupProgressDocRef: FirebaseDocRef, transaction: FirebaseFirestore.Transaction) {
  if (signupProgressDocRef == null) {
    throw new Error("Cannot update signup progress for updateExpertCategory because signup progress doc ref is null");
  }
  transaction.update(signupProgressDocRef, {
    "updatedExpertCategory": true,
  });
}

function updateExpertInfo(expertInfoRef: FirebaseDocRef, transaction: FirebaseFirestore.Transaction, updatedCategories: [string, string]) {
  const newMajorCategory = updatedCategories[0];
  const newMinorCategory = updatedCategories[1];
  if (expertInfoRef == null) {
    throw new Error("Cannot update expert category for updateExpertCategory because expert info doc ref is null");
  }
  transaction.update(expertInfoRef, {
    "majorExpertCategory": newMajorCategory,
    "minorExpertCategory": newMinorCategory,
  });
}
