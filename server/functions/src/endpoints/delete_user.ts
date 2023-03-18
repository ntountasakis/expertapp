import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getExpertRateDocumentRef, getPrivateUserDocument, getPrivateUserDocumentRef, getPublicExpertInfoDocumentRef, getPublicUserDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { PrivateUserInfo } from "../../../shared/src/firebase/firestore/models/private_user_info";
import { deleteStripeCustomer } from "../../../shared/src/stripe/util";
import { StripeProvider } from "../../../shared/src/stripe/stripe_provider";

export const deleteUser = functions.https.onCall(async (data, context) => {
    if (context.auth == null) {
        throw new Error("Cannot call by unauthorized users");
    }
    //todo: prompt user to delete stripe connected account before we proceed
    try {
        const uid = context.auth.uid;
        const privateUserInfo: PrivateUserInfo = await admin.firestore().runTransaction(async (transaction) => {
            const privateUserInfo: PrivateUserInfo = await getPrivateUserDocument({ transaction: transaction, uid: uid });
            transaction.delete(getPublicUserDocumentRef({ uid: uid }));
            transaction.delete(getPrivateUserDocumentRef({ uid: uid }));
            transaction.delete(getPublicExpertInfoDocumentRef({ uid: uid }));
            transaction.delete(getExpertRateDocumentRef({ expertUid: uid }));
            return privateUserInfo;
        });

        await deleteStripeCustomer({ stripe: StripeProvider.STRIPE, customerId: privateUserInfo.stripeCustomerId });
        await admin.auth().deleteUser(uid);
    } catch (e) {
        console.error(e);
        return {
            success: false,
            message: "Please contact customer service. We are experiencing technical difficulties",
        };
    }
    return {
        success: true,
        message: "Your account was deleted successfully",
    };
});