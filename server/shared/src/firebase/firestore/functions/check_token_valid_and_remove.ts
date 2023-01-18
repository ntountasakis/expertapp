import * as admin from "firebase-admin";
import { getSignUpTokenDocumentRef } from "../document_fetchers/fetchers";
export async function checkTokenValidAndRemove({ token }: { token: string }): Promise<boolean> {
    return await admin.firestore().runTransaction(async (transaction) => {
        const docRef = getSignUpTokenDocumentRef({ token: token });
        const doc = await transaction.get(docRef);
        if (!doc.exists) {
            return false;
        }
        transaction.delete(docRef);
        return true;
    });
}