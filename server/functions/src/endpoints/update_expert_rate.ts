
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getExpertRateDocumentRef, getPrivateUserDocument} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {PrivateUserInfo} from "../../../shared/src/firebase/firestore/models/private_user_info";

export const updateExpertRate = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const uid = context.auth.uid;
  const newCentsPerMinute : number = data.centsPerMinute;
  const newCentsStartCall : number = data.centsStartCall;

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

    if (newCentsStartCall <= 0) {
      return {
        success: false,
        message: "Rate earned to accept a call must be greater than 0",
      };
    }

    await admin.firestore().runTransaction(async (transaction) => {
      const privateUserDoc: PrivateUserInfo = await getPrivateUserDocument({transaction: transaction, uid: uid});

      if (privateUserDoc.stripeConnectedId == null) {
        throw new Error(`Cannot update expert rate, user ${uid} has no stripeConnectedId`);
      }
      transaction.update(getExpertRateDocumentRef({expertUid: uid}), {
        "centsPerMinute": newCentsPerMinute,
        "centsCallStart": newCentsStartCall,
      });
    });
    console.log(`Updated expert rate for ${uid}. New rate: ${newCentsPerMinute} cents per minute and ${newCentsStartCall} cents to start call`);
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
