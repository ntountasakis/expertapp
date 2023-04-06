import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { FirebaseDynamicLinkProvider } from "../../../shared/src/firebase/dynamic_links/web_api_key";
import { getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";

export const generateExpertProfileDynamicLink = functions.https.onCall(async (data, context) => {
    const expertUid: string = data.expertUid;
    if (expertUid == null || expertUid === "" || expertUid === undefined) {
        throw new Error(`Expert uid is empty`);
    }

    const exists = await admin.firestore().runTransaction(async (transaction) => {
        const publicExpertInfoDoc = await transaction.get(getPublicExpertInfoDocumentRef({ uid: expertUid }));
        return publicExpertInfoDoc.exists;
    });
    if (!exists) {
        throw new Error(`User ${expertUid} is not an expert`);
    }
    const link: string = await FirebaseDynamicLinkProvider.generateDynamicLinkExpertProfile({ expertUid: expertUid });
    Logger.log({
        logName: "generateExpertProfileDynamicLink ", message: `Generated dynamic link for expert profile for uid ${expertUid}: ${link}`,
        labels: new Map([["expertId", expertUid]]),
    });
    return link;
});
