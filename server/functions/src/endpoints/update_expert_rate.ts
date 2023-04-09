import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getExpertRateDocumentRef, getPrivateUserDocument, getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
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

    if (newCentsPerMinute > StripeProvider.MAX_MINUTELY_RATE_CENTS) {
      return {
        success: false,
        message: "Rate per minute cannot exceed " + StripeProvider.MAX_MINUTELY_RATE_CENTS + " cents",
      };
    }

    if (newCentsStartCall < StripeProvider.MIN_BILLABLE_AMOUNT_CENTS) {
      return {
        success: false,
        message: "Rate to accept a call must at least " + StripeProvider.MIN_BILLABLE_AMOUNT_CENTS + " cents",
      };
    }

    if (newCentsStartCall > StripeProvider.MAX_START_CALL_RATE_CENTS) {
      return {
        success: false,
        message: "Rate to accept a call cannot exceed " + StripeProvider.MAX_START_CALL_RATE_CENTS + " cents",
      };
    }

    const success = await admin.firestore().runTransaction(async (transaction) => {
      const privateUserDoc: PrivateUserInfo = await getPrivateUserDocument({ transaction: transaction, uid: uid });
      const publicExpertInfoDoc = await transaction.get(getPublicExpertInfoDocumentRef({ uid: uid }));

      if (privateUserDoc.stripeConnectedId == null) {
        Logger.logError({
          logName: "updateExpertRate", message: `Cannot update expert rate for ${uid} because they have no stripe connected id`,
          labels: new Map([["expertId", uid]]),
        });
        return false;
      }
      if (!publicExpertInfoDoc.exists) {
        Logger.logError({
          logName: "updateExpertRate", message: `Cannot update expert rate for ${uid} because they are not an expert`,
          labels: new Map([["expertId", uid]]),
        });
        return false;
      }
      transaction.update(getExpertRateDocumentRef({ expertUid: uid }), {
        "centsPerMinute": newCentsPerMinute,
        "centsCallStart": newCentsStartCall,
      });
      Logger.log({
        logName: "updateExpertRate", message: `Updated expert rate for ${uid}. New rate: ${newCentsPerMinute} cents per minute and ${newCentsStartCall} cents to start call`,
        labels: new Map([["expertId", uid]]),
      });
      return true;
    });
    return {
      success: success,
      message: success ? "Your expert rate has been updated successfully" : "Internal Server Error",
    };
  } catch (e) {
    return {
      success: false,
      message: "Internal Server Error",
    };
  }
});
