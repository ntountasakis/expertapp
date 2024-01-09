import * as admin from "firebase-admin";
import {getPrivateUserDocumentRef, getPublicUserDocumentNoTransact} from "../document_fetchers/fetchers";
import {PrivateUserInfo} from "../models/private_user_info";
import {StripeProvider} from "../../../stripe/stripe_provider";
import {createStripeConnectAccount} from "../../../stripe/util";
import {PublicUserInfo} from "../models/public_user_info";

export async function updateConnectedAccountPrivateUserInfo({uid, privateUserInfo}:
  { uid: string, privateUserInfo: PrivateUserInfo }): Promise<string> {
  const publicUserInfo: PublicUserInfo = await getPublicUserDocumentNoTransact({uid: uid});
  const newConnectedAccountId: string = await createStripeConnectAccount({
    stripe: StripeProvider.STRIPE, firstName: publicUserInfo.firstName, lastName: publicUserInfo.lastName,
    email: privateUserInfo.email,
  });
  await admin.firestore().runTransaction(async (transaction) => {
    transaction.update(getPrivateUserDocumentRef({uid: uid}), {
      "stripeConnectedId": newConnectedAccountId,
    });
  });

  return newConnectedAccountId;
}
