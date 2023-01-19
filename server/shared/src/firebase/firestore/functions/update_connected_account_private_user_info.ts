import * as admin from "firebase-admin";
import { getPrivateUserDocumentRef } from "../document_fetchers/fetchers";
import { PrivateUserInfo } from "../models/private_user_info";
import { StripeProvider } from "../../../stripe/stripe_provider";
import { createStripeConnectAccount } from "../../../stripe/util";
import { PublicExpertInfo } from "../models/public_expert_info";

export async function updateConnectedAccountPrivateUserInfo({ uid, publicExpertInfo, privateUserInfo }:
  { uid: string, publicExpertInfo: PublicExpertInfo, privateUserInfo: PrivateUserInfo }): Promise<string> {
  const newConnectedAccountId: string = await createStripeConnectAccount({
    stripe: StripeProvider.STRIPE, firstName: publicExpertInfo.firstName, lastName: publicExpertInfo.lastName,
    email: privateUserInfo.email
  });
  await admin.firestore().runTransaction(async (transaction) => {
    transaction.update(getPrivateUserDocumentRef({ uid: uid }), {
      "stripeConnectedId": newConnectedAccountId,
    });
  });

  return newConnectedAccountId;
}
