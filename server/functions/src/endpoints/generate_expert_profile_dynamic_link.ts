import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { FirebaseDynamicLinkProvider } from "../../../shared/src/firebase/dynamic_links/web_api_key";
import { getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";

export const generateExpertProfileDynamicLink = functions.https.onCall(async (data, context) => {
    if (context.auth == null) {
        throw new Error("Cannot call by unauthorized users");
    }
    const uid = context.auth.uid;
    const exists = await admin.firestore().runTransaction(async (transaction) => {
        const publicExpertInfoDoc = await transaction.get(getPublicExpertInfoDocumentRef({ uid: uid }));
        return publicExpertInfoDoc.exists;
    });
    if (!exists) {
        throw new Error(`User ${uid} is not an expert`);
    }
    const link: string = await FirebaseDynamicLinkProvider.generateDynamicLinkExpertProfile({ expertUid: uid });
    console.log(`Generated dynamic link for expert profile for uid ${uid}: ${link}`);
    return link;
});
