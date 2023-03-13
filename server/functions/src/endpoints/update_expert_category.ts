import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getExpertCategoryRef, getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";

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

        await admin.firestore().runTransaction(async (transaction) => {
            const publicExpertDoc = await transaction.get(getPublicExpertInfoDocumentRef({ uid: uid }));
            const expertCategoryDoc = await transaction.get(getExpertCategoryRef({ majorCategory: newMajorCategory }));
            if (!publicExpertDoc.exists) {
                throw new Error(`Cannot update expert category, ${uid} is not a expert`);
            }
            if (!expertCategoryDoc.exists) {
                throw new Error(`Cannot update expert category, ${newMajorCategory} is not a valid major category`);
            }
            const categoryTypes: Array<String> = Object.keys(expertCategoryDoc.data() as Object);
            if (!categoryTypes.includes(newMinorCategory)) {
                throw new Error(`Cannot update expert category, ${newMinorCategory} is not a valid minor category`);
            }
            transaction.update(getPublicExpertInfoDocumentRef({ uid: uid }), {
                "majorExpertCategory": newMajorCategory,
                "minorExpertCategory": newMinorCategory,
            });
        });
        console.log(`Updated expert category for ${uid}. New major category: ${newMajorCategory} new minor category: ${newMinorCategory}`);
    } catch (e) {
        console.error(`Failed to update expert category for ${uid}. Error: ${e}`);
        return {
            success: false,
            message: "Internal Server Error",
        };
    }
    return {
        success: true,
        message: "Your categories have been updated successfully",
    };
});
