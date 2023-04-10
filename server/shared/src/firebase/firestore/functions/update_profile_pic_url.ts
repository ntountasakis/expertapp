import { Logger } from "../../../google_cloud/google_cloud_logger";
import { getPublicExpertInfoDocumentRef } from "../document_fetchers/fetchers";

export async function updateProfilePicUrl({ transaction, uid, profilePicUrl, fromSignUpFlow }:
    { transaction: FirebaseFirestore.Transaction, uid: string, profilePicUrl: string, fromSignUpFlow: boolean }): Promise<boolean> {
    const publicInfoDocRef = getPublicExpertInfoDocumentRef({ uid: uid, fromSignUpFlow: fromSignUpFlow });
    const publicExpertInfoDoc = await transaction.get(publicInfoDocRef);
    if (!publicExpertInfoDoc.exists) {
        Logger.logError({
            logName: "updateProfilePicture", message: `Cannot update profile pic for user ${uid} because they are not an expert. From sign up flow: ${fromSignUpFlow}`,
            labels: new Map([["expertId", uid]])
        });
        return false;
    }
    transaction.update(publicInfoDocRef, "profilePicUrl", profilePicUrl);
    Logger.log({
        logName: "updateProfilePicture", message: `profile pic firestore updated to ${profilePicUrl} for user ${uid}. From sign up flow: ${fromSignUpFlow}`,
        labels: new Map([["expertId", uid]])
    });
    return true;
}
