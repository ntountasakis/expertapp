import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getExpertCategoryRef, getExpertSignUpProgressDocumentRef, getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";

export const updateExpertCategory = functions.https.onCall(async (data, context) => {
    if (context.auth == null) {
        throw new Error("Cannot call by unauthorized users");
    }
    const uid = context.auth.uid;
    const newMajorCategory: string = data.newMajorCategory;
    const newMinorCategory: string = data.newMinorCategory;
    const fromSignUpFlow: boolean = data.fromSignUpFlow;

    try {
        if (uid == null || newMajorCategory == null || newMinorCategory == null || fromSignUpFlow == null) {
            throw new Error("Cannot update expert category, some attributes null");
        }

        const success = await admin.firestore().runTransaction(async (transaction) => {
            const publicExpertDocRef = getPublicExpertInfoDocumentRef({ uid: uid, fromSignUpFlow: fromSignUpFlow });
            const publicExpertDoc = await transaction.get(publicExpertDocRef);
            const expertCategoryDoc = await transaction.get(getExpertCategoryRef({ majorCategory: newMajorCategory }));
            const expertSignUpProgressDocRef = getExpertSignUpProgressDocumentRef({ uid: uid });
            const expertSignUpProgressDoc = fromSignUpFlow ? await transaction.get(expertSignUpProgressDocRef) : null;
            if (!publicExpertDoc.exists) {
                Logger.logError({
                    logName: "updateExpertCategory", message: `Cannot update expert category for ${uid} because they are not a expert. From sign up flow: ${fromSignUpFlow}`,
                    labels: new Map([["expertId", uid]]),
                });
                return false;
            }
            if (!expertCategoryDoc.exists) {
                Logger.logError({
                    logName: "updateExpertCategory", message: `Cannot update expert category for ${uid} because they are not a expert. From sign up flow: ${fromSignUpFlow}`,
                    labels: new Map([["expertId", uid]]),
                });
                return false;
            }
            if (fromSignUpFlow && !(expertSignUpProgressDoc!.exists)) {
                Logger.logError({
                    logName: "updateExpertCategory", message: `Cannot update expert category for ${uid} because they have no expert sign up progress doc.`,
                    labels: new Map([["expertId", uid]])
                });
                return false;
            }
            const categoryTypes: Array<String> = Object.keys(expertCategoryDoc.data() as Object);
            if (!categoryTypes.includes(newMinorCategory)) {
                Logger.logError({
                    logName: "updateExpertCategory", message: `Cannot update expert category for ${uid} because they are not a expert. From sign up flow: ${fromSignUpFlow}`,
                    labels: new Map([["expertId", uid]]),
                });
                return false;
            }
            if (fromSignUpFlow) {
                transaction.update(expertSignUpProgressDocRef, "updatedExpertCategory", true);
            }
            transaction.update(publicExpertDocRef, {
                "majorExpertCategory": newMajorCategory,
                "minorExpertCategory": newMinorCategory,
            });
            Logger.log({
                logName: "updateExpertCategory", message: `Updated expert category for ${uid}. New major category: ${newMajorCategory} new minor category: ${newMinorCategory} From sign up flow: ${fromSignUpFlow}`,
                labels: new Map([["expertId", uid]]),
            });
            return true;
        });
        return {
            success: success,
            message: success ? "Your categories have been updated successfully" : "Internal Server Error",
        };
    } catch (e) {
        Logger.logError({
            logName: "updateExpertCategory", message: `Failed to update expert category for ${uid}. From sign up flow ${fromSignUpFlow} Error: ${e}`,
            labels: new Map([["expertId", uid]]),
        });
        return {
            success: false,
            message: "Internal Server Error",
        };
    }
});
