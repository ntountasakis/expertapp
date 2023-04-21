import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getExpertRateDocumentRef, getPrivateUserDocument} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {PrivateUserInfo} from "../../../shared/src/firebase/firestore/models/private_user_info";
import {StripeProvider} from "../../../shared/src/stripe/stripe_provider";
import {Logger} from "../../../shared/src/google_cloud/google_cloud_logger";
import {FirebaseDocRef, getExpertInfoConditionalOnSignup} from "../../../shared/src/firebase/firestore/functions/expert_info_conditional_sign_up_fetcher";

export const updateExpertRate = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const uid = context.auth.uid;
  const newCentsPerMinute: number = data.centsPerMinute;
  const newCentsStartCall: number = data.centsStartCall;
  const fromSignUpFlow: boolean = data.fromSignUpFlow;
  const version: string = data.version;

  try {
    if (uid == null || newCentsPerMinute == null || newCentsStartCall == null || fromSignUpFlow == null || version == null) {
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
      const privateUserDoc: PrivateUserInfo = await getPrivateUserDocument({transaction: transaction, uid: uid});
      if (privateUserDoc.stripeConnectedId == null) {
        Logger.logError({
          logName: "updateExpertRate", message: `Cannot update expert rate for ${uid} because they have no stripe connected id`,
          labels: new Map([["expertId", uid], ["version", version]]),
        });
        return false;
      }
      const wasSuccess: boolean = await getExpertInfoConditionalOnSignup({functionNameForLogging: "updateExpertRate",
        uid: uid, fromSignUpFlow: fromSignUpFlow,
        transaction: transaction, version: version, updateSignupProgressFunc: updateSignupProgress,
        updateExpertInfoFunc: updateExpertInfo,
        contextData: [newCentsPerMinute, newCentsStartCall],
      });
      if (wasSuccess) {
        Logger.log({
          logName: "updateExpertRate", message: `Updated expert rate for ${uid}. \
        New rate: ${newCentsPerMinute} cents per minute and ${newCentsStartCall} cents to start call`,
          labels: new Map([["expertId", uid], ["version", version]]),
        });
      }
      return wasSuccess;
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

function updateSignupProgress(signupProgressDocRef: FirebaseDocRef, transaction: FirebaseFirestore.Transaction) {
  if (signupProgressDocRef == null) {
    throw new Error("Cannot update signup progress for updateExpertCategory because signup progress doc ref is null");
  }
  transaction.update(signupProgressDocRef, {
    "updatedCallRate": true,
  });
}

function updateExpertInfo(expertInfoRef: FirebaseDocRef, transaction: FirebaseFirestore.Transaction, updatedRates: [number, number]) {
  if (expertInfoRef == null) {
    throw new Error("Cannot update expert category for updateExpertCategory because expert info doc ref is null");
  }
  const newCentsPerMinute = updatedRates[0];
  const newCentsStartCall = updatedRates[1];
  transaction.update(getExpertRateDocumentRef({expertUid: expertInfoRef.id}), {
    "centsPerMinute": newCentsPerMinute,
    "centsCallStart": newCentsStartCall,
  });
}
