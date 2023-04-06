import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getExpertRateDocumentRef, getPrivateUserDocument } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { PrivateUserInfo } from "../../../shared/src/firebase/firestore/models/private_user_info";
import { StripeProvider } from "../../../shared/src/stripe/stripe_provider";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";

export const updateExpertRate = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const uid = context.auth.uid;
  const newCentsPerMinute: number = data.centsPerMinute;
  const newCentsStartCall: number = data.centsStartCall;

  try {
    if (uid == null || newCentsPerMinute == null || newCentsStartCall == null) {
      throw new Error("Cannot update expert rate, some attributes null");
    }

    if (newCentsPerMinute <= 0) {
      return {
        success: false,
        message: "Rate per minute must be greater than 0",
      };
    }

    if (newCentsStartCall < StripeProvider.MIN_BILLABLE_AMOUNT_CENTS) {
      return {
        success: false,
        message: "Rate earned to accept a call must at least " + StripeProvider.MIN_BILLABLE_AMOUNT_CENTS + " cents",
      };
    }

    await admin.firestore().runTransaction(async (transaction) => {
      const privateUserDoc: PrivateUserInfo = await getPrivateUserDocument({ transaction: transaction, uid: uid });

      if (privateUserDoc.stripeConnectedId == null) {
        throw new Error(`Cannot update expert rate, user ${uid} has no stripeConnectedId`);
      }
      transaction.update(getExpertRateDocumentRef({ expertUid: uid }), {
        "centsPerMinute": newCentsPerMinute,
        "centsCallStart": newCentsStartCall,
      });
    });
    Logger.log({
      logName: "updateExpertRate", message: `Updated expert rate for ${uid}. New rate: ${newCentsPerMinute} cents per minute and ${newCentsStartCall} cents to start call`,
      labels: new Map([["expertId", uid]]),
    });
  } catch (e) {
    return {
      success: false,
      message: "Internal Server Error",
    };
  }
  return {
    success: true,
    message: "Your rates have been updated successfully",
  };
});
