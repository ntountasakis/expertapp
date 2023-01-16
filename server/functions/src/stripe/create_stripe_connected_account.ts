import * as admin from "firebase-admin";
import {getPrivateUserDocument, getUserDocumentRef} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {PrivateUserInfo} from "../../../shared/src/firebase/firestore/models/private_user_info";
import {StripeProvider} from "../../../shared/src/stripe/stripe_provider";
import {createStripeConnectAccount} from "../../../shared/src/stripe/util";

export async function createStripeConnectedAccount({uid} : {uid: string}): Promise<string> {
  const privateUserInfo: PrivateUserInfo = await admin.firestore().runTransaction(async (transaction) => {
    return await getPrivateUserDocument({transaction: transaction, uid: uid});
  });
  if (privateUserInfo.stripeConnectedId !== null) {
    return privateUserInfo.stripeConnectedId;
  }

  const newConnectedAccountId: string = await createStripeConnectAccount({
    stripe: StripeProvider.STRIPE, firstName: privateUserInfo.firstName, lastName: privateUserInfo.lastName,
    email: privateUserInfo.email});

  await admin.firestore().runTransaction(async (transaction) => {
    transaction.update(getUserDocumentRef({uid: uid}), {
      "stripeConnectedId": newConnectedAccountId,
    });
  });

  return newConnectedAccountId;
}
