import {Logger} from "../../../google_cloud/google_cloud_logger";
import {getExpertSignUpProgressDocumentRef, getPublicExpertInfoDocumentRef} from "../document_fetchers/fetchers";


export type FirebaseDocRef = FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> | null;

export async function getExpertInfoConditionalOnSignup({functionNameForLogging, fromSignUpFlow, uid, transaction, version,
  updateSignupProgressFunc: updateSignupProgressFunc, updateExpertInfoFunc: updateExpertInfoFunc, contextData}: {
        fromSignUpFlow: boolean, uid: string,
        transaction: FirebaseFirestore.Transaction,
        version: string, functionNameForLogging: string,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        updateSignupProgressFunc: (func: FirebaseDocRef, transaction: FirebaseFirestore.Transaction, contextData: any) => void,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        updateExpertInfoFunc: (func: FirebaseDocRef, transaction: FirebaseFirestore.Transaction, contextData: any) => void,
        contextData: unknown,
    }): Promise<boolean> {
  const publicExpertInfoDocRef = getPublicExpertInfoDocumentRef({uid: uid, fromSignUpFlow: fromSignUpFlow});
  const publicExpertInfoDoc = await transaction.get(publicExpertInfoDocRef);
  if (!publicExpertInfoDoc.exists) {
    Logger.logError({
      logName: functionNameForLogging, message: `Cannot complete ${functionNameForLogging} for ${uid} they have no expert info doc.\
            From sign up flow: ${fromSignUpFlow}`,
      labels: new Map([["expertId", uid], ["version", version]]),
    });
    return false;
  }
  if (fromSignUpFlow) {
    const progressDocRef = getExpertSignUpProgressDocumentRef({uid: uid});
    const expertSignUpProgressDoc = await transaction.get(progressDocRef);
    if (!expertSignUpProgressDoc.exists) {
      Logger.logError({
        logName: functionNameForLogging, message: `Cannot complete ${functionNameForLogging} for ${uid} because they have no sign up progress document.`,
        labels: new Map([["expertId", uid], ["version", version]]),
      });
      return false;
    }
    updateSignupProgressFunc(progressDocRef, transaction, contextData);
  }
  updateExpertInfoFunc(publicExpertInfoDocRef, transaction, contextData);
  return true;
}
