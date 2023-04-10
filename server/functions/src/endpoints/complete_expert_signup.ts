import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";
import { PublicExpertInfo } from "../../../shared/src/firebase/firestore/models/public_expert_info";

export const completeExpertSignUp = functions.https.onCall(async (data, context) => {
    if (context.auth == null) {
        throw new Error("Cannot call by unauthorized users");
    }
    const uid = context.auth.uid;

    try {
        const success = await admin.firestore().runTransaction(async (transaction) => {
            const stagingPublicExpertDoc = await transaction.get(getPublicExpertInfoDocumentRef({ uid: uid, fromSignUpFlow: true }));
            if (!stagingPublicExpertDoc.exists) {
                Logger.logError({
                    logName: "completeExpertSignUp", message: `Cannot complete expert sign up for ${uid} because they have no staging doc`,
                    labels: new Map([["expertId", uid]]),
                });
                return false;
            }
            const finalPublicExpertRef = getPublicExpertInfoDocumentRef({ uid: uid, fromSignUpFlow: false });

            transaction.set(finalPublicExpertRef, stagingPublicExpertDoc.data() as PublicExpertInfo);
            transaction.delete(stagingPublicExpertDoc.ref);
            Logger.log({
                logName: "completeExpertSignUp", message: `Completed expert sign up for ${uid}`,
                labels: new Map([["expertId", uid]]),
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
            labels: new Map([["expertId", uid]]),
        });
        return {
            success: false,
            message: "Internal Server Error",
        };
    }
});
