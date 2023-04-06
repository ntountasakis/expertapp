import { Logger } from "../../../google_cloud/google_cloud_logger";
import { getPublicExpertInfoDocumentRef } from "../document_fetchers/fetchers";

export function updateProfilePicUrl({ transaction, uid, profilePicUrl }:
    { transaction: FirebaseFirestore.Transaction, uid: string, profilePicUrl: string, }): void {
    const publicInfoDocRef = getPublicExpertInfoDocumentRef({ uid: uid });
    transaction.update(publicInfoDocRef, "profilePicUrl", profilePicUrl);
    Logger.log({
        logName: "updateProfilePicture", message: `profile pic firestore updated to ${profilePicUrl} for user ${uid}.`,
        labels: new Map([["expertId", uid]])
    });
}
