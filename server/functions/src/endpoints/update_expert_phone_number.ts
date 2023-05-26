import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getPrivateUserDocumentRef} from "../shared/src/firebase/firestore/document_fetchers/fetchers";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";

export const updateExpertPhoneNumber = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const uid = context.auth.uid;
  const version: string = data.version;
  const phoneNumber: string = data.phoneNumber;
  const phoneNumberDialCode: string = data.phoneNumberDialCode;
  const phoneNumberIsoCode: string = data.phoneNumberIsoCode;
  const consentsToSms: boolean = data.consentsToSms;

  try {
    if (uid == null || version == null || phoneNumber == null || phoneNumberDialCode == null ||
      phoneNumberIsoCode == null || consentsToSms == null) {
      throw new Error("Cannot update expert phone number, some attributes null");
    }

    const success = await admin.firestore().runTransaction(async (transaction) => {
      const privateUserDoc = await transaction.get(getPrivateUserDocumentRef({uid: uid}));
      if (!privateUserDoc.exists) {
        Logger.logError({
          logName: "updateExpertPhoneNumber", message: `Cannot update expert phone number for ${uid} \
          because private user doc does not exist`,
          labels: new Map([["expertId", uid], ["version", version]]),
        });
        return false;
      }

      const phoneNumberDetails = {
        "phoneNumber": phoneNumber,
        "phoneNumberDialCode": phoneNumberDialCode,
        "phoneNumberIsoCode": phoneNumberIsoCode,
        "consentsToSms": consentsToSms,
      };

      transaction.update(privateUserDoc.ref, phoneNumberDetails);
      Logger.log({
        logName: "updateExpertPhoneNumber", message: `Updated expert phone number for ${uid}. \
          Phone number: ${phoneNumber} consented to text messages: ${consentsToSms}`,
        labels: new Map([["expertId", uid], ["version", version]]),
      });
      return true;
    });
    return {
      success: success,
      message: success ? "Your phone number & consent has been updated" : "Internal Server Error",
    };
  } catch (e) {
    Logger.logError({
      logName: "updateExpertPhoneNumber", message: `Failed to update phone number for ${uid}. Error: ${e}`,
      labels: new Map([["expertId", uid], ["version", version]]),
    });
    return {
      success: false,
      message: "Internal Server Error",
    };
  }
});
