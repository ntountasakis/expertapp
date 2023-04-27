import {Logger} from "../../../google_cloud/google_cloud_logger";
import {FirebaseDocRef, getExpertInfoConditionalOnSignup} from "./expert_info_conditional_sign_up_fetcher";

export async function updateProfilePicUrl({transaction, uid, profilePicUrl, fromSignUpFlow, version}:
    { transaction: FirebaseFirestore.Transaction, uid: string, profilePicUrl: string, fromSignUpFlow: boolean, version: string }): Promise<boolean> {
  const wasSuccess: boolean = await getExpertInfoConditionalOnSignup({
    functionNameForLogging: "updateProfilePicture",
    uid: uid, fromSignUpFlow: fromSignUpFlow,
    transaction: transaction, version: version, updateSignupProgressFunc: updateSignupProgress,
    updateExpertInfoFunc: updateExpertInfo,
    contextData: profilePicUrl,
  });
  if (wasSuccess) {
    Logger.log({
      logName: "updateProfilePicture", message: `profile pic firestore updated to ${profilePicUrl} for user ${uid}. From sign up flow: ${fromSignUpFlow}`,
      labels: new Map([["expertId", uid]]),
    });
  }
  return wasSuccess;
}

function updateSignupProgress(signupProgressDocRef: FirebaseDocRef, transaction: FirebaseFirestore.Transaction) {
  if (signupProgressDocRef == null) {
    throw new Error("Cannot update signup progress for updateProfilePicUrl because signup progress doc ref is null");
  }
  transaction.update(signupProgressDocRef, {
    "updatedProfilePic": true,
  });
}

function updateExpertInfo(expertInfoRef: FirebaseDocRef, transaction: FirebaseFirestore.Transaction, profilePicUrl: string) {
  if (expertInfoRef == null) {
    throw new Error("Cannot update expert category for updateProfilePicUrl because expert info doc ref is null");
  }
  transaction.update(expertInfoRef, "profilePicUrl", profilePicUrl);
}
