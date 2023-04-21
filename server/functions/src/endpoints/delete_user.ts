import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getExpertRateDocumentRef, getExpertSignUpProgressDocumentRef, getPrivateUserDocumentRef, getPublicExpertInfoDocumentRef, getPublicUserDocumentRef, getStatusDocumentRef} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {PrivateUserInfo} from "../../../shared/src/firebase/firestore/models/private_user_info";
import {deleteStripeConnectedAccount, deleteStripeCustomer} from "../../../shared/src/stripe/util";
import {StripeProvider} from "../../../shared/src/stripe/stripe_provider";
import allBalancesZeroStripeConnectedAccount from "../../../shared/src/stripe/stripe_check_balances";
import configureStripeProviderForFunctions from "../stripe/stripe_provider_functions_configurer";
import {Logger} from "../../../shared/src/google_cloud/google_cloud_logger";

export const deleteUser = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  try {
    const uid = context.auth.uid;
    const version: string = data.version;
    const privateUserInfo: PrivateUserInfo | null = await admin.firestore().runTransaction(async (transaction) => {
      const doc = await transaction.get(getPrivateUserDocumentRef({uid: uid}));
      return doc.exists ? doc.data() as PrivateUserInfo : null;
    });
    if (privateUserInfo != null) {
      await configureStripeProviderForFunctions();
      if (privateUserInfo.stripeConnectedId != null && privateUserInfo.stripeConnectedId !== "") {
        const [hasZeroBalance, nonZeroMessage] = await allBalancesZeroStripeConnectedAccount(
            {stripe: StripeProvider.STRIPE, connectedAccountId: privateUserInfo.stripeConnectedId});
        if (!hasZeroBalance) {
          return {
            success: false,
            message: "Cannot delete account yet, all balances in your Stripe dashboard must be zero. " + nonZeroMessage,
          };
        }
        await deleteStripeConnectedAccount({stripe: StripeProvider.STRIPE, connectedAccountId: privateUserInfo.stripeConnectedId});
      }
      await deleteStripeCustomer({stripe: StripeProvider.STRIPE, customerId: privateUserInfo.stripeCustomerId});
      await admin.firestore().runTransaction(async (transaction) => {
        transaction.delete(getPublicUserDocumentRef({uid: uid}));
        transaction.delete(getPrivateUserDocumentRef({uid: uid}));
        transaction.delete(getPublicExpertInfoDocumentRef({uid: uid, fromSignUpFlow: false}));
        transaction.delete(getPublicExpertInfoDocumentRef({uid: uid, fromSignUpFlow: true}));
        transaction.delete(getExpertSignUpProgressDocumentRef({uid: uid}));
        transaction.delete(getExpertRateDocumentRef({expertUid: uid}));
        transaction.delete(getStatusDocumentRef({uid: uid}));
      });
    }
    await admin.auth().deleteUser(uid);
    Logger.log({
      logName: "deleteUser", message: `Deleted user ${uid}`,
      labels: new Map([["userId", uid], ["version", version]]),
    });
  } catch (e) {
    Logger.logError({
      logName: "deleteUser", message: `Cannot delete user ${context.auth.uid} because of error ${e}`,
    });
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
