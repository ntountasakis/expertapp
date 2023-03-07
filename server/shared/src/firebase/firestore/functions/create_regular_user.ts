import * as admin from "firebase-admin";
import { getPrivateUserDocumentRef } from "../document_fetchers/fetchers";
import { PrivateUserInfo } from "../models/private_user_info";

export async function createRegularUser({ uid, email, stripeCustomerId }:
    {
        uid: string, firstName: string, lastName: string, email: string,
        profilePicUrl: string, stripeCustomerId: string
    }): Promise<void> {
    const privateUserInfo: PrivateUserInfo = {
        "email": email,
        "stripeCustomerId": stripeCustomerId,
        "stripeConnectedId": ""
    };
    await admin.firestore().runTransaction(async (transaction) => {
        transaction.set(getPrivateUserDocumentRef({ uid: uid }), privateUserInfo);
    });
}
