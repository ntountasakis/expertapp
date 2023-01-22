import { getPublicExpertInfoDocumentRef } from "../document_fetchers/fetchers";

export function updateProfilePicUrl({ transaction, uid, profilePicUrl }:
    { transaction: FirebaseFirestore.Transaction, uid: string, profilePicUrl: string, }): void {
    const publicInfoDocRef = getPublicExpertInfoDocumentRef({ uid: uid });
    transaction.update(publicInfoDocRef, "profilePicUrl", profilePicUrl);
    console.log(`profile pic firestore updated to ${profilePicUrl} for user ${uid}.`)
}
