import * as admin from "firebase-admin";
import { getUserDocumentRef } from "../document_fetchers/fetchers";
import { PrivateUserInfo } from "../models/private_user_info";
import { StripeProvider } from "../../../stripe/stripe_provider";
import { createStripeConnectAccount } from "../../../stripe/util";

export async function updateConnectedAccountPrivateUserInfo({ uid, privateUserInfo }: { uid: string, privateUserInfo: PrivateUserInfo }): Promise<string> {
  const newConnectedAccountId: string = await createStripeConnectAccount({
    stripe: StripeProvider.STRIPE, firstName: privateUserInfo.firstName, lastName: privateUserInfo.lastName,
    email: privateUserInfo.email
  });
  await admin.firestore().runTransaction(async (transaction) => {
    transaction.update(getUserDocumentRef({ uid: uid }), {
      "stripeConnectedId": newConnectedAccountId,
    });
  });

  return newConnectedAccountId;
}
