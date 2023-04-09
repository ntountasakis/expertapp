import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getExpertCategoryRef, getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";

export const updateExpertCategory = functions.https.onCall(async (data, context) => {
    if (context.auth == null) {
        throw new Error("Cannot call by unauthorized users");
    }
    const uid = context.auth.uid;
    const newMajorCategory: string = data.newMajorCategory;
    const newMinorCategory: string = data.newMinorCategory;

    try {
        if (uid == null || newMajorCategory == null || newMinorCategory == null) {
            throw new Error("Cannot update expert category, some attributes null");
        }

        const success = await admin.firestore().runTransaction(async (transaction) => {
            const publicExpertDoc = await transaction.get(getPublicExpertInfoDocumentRef({ uid: uid }));
            const expertCategoryDoc = await transaction.get(getExpertCategoryRef({ majorCategory: newMajorCategory }));
            if (!publicExpertDoc.exists) {
                Logger.logError({
                    logName: "updateExpertCategory", message: `Cannot update expert category for ${uid} because they are not a expert.`,
                    labels: new Map([["expertId", uid]]),
                });
                return false;
            }
            if (!expertCategoryDoc.exists) {
                Logger.logError({
                    logName: "updateExpertCategory", message: `Cannot update expert category, ${newMajorCategory} is not a valid major category`,
                    labels: new Map([["expertId", uid]]),
                });
                return false;
            }
            const categoryTypes: Array<String> = Object.keys(expertCategoryDoc.data() as Object);
            if (!categoryTypes.includes(newMinorCategory)) {
                Logger.logError({
                    logName: "updateExpertCategory", message: `Cannot update expert category, ${newMinorCategory} is not a valid minor category`,
                    labels: new Map([["expertId", uid]]),
                });
                return false;
            }
            transaction.update(getPublicExpertInfoDocumentRef({ uid: uid }), {
                "majorExpertCategory": newMajorCategory,
                "minorExpertCategory": newMinorCategory,
            });
            Logger.log({
                logName: "updateExpertCategory", message: `Updated expert category for ${uid}. New major category: ${newMajorCategory} new minor category: ${newMinorCategory}`,
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
            logName: "updateExpertCategory", message: `Failed to update expert category for ${uid}. Error: ${e}`,
            labels: new Map([["expertId", uid]]),
        });
        return {
            success: false,
            message: "Internal Server Error",
        };
    }
});
