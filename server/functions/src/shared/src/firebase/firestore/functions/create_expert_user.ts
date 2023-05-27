import * as admin from "firebase-admin";
import {Logger} from "../../../google_cloud/google_cloud_logger";
import {StripeProvider} from "../../../stripe/stripe_provider";
import {getExpertRateDocumentRef, getExpertSignUpProgressDocumentRef, getPublicExpertInfoDocumentRef, getPublicUserDocument} from "../document_fetchers/fetchers";
import {DayAvailability, WeekAvailability} from "../models/expert_availability";
import {ExpertRate} from "../models/expert_rate";
import {PublicExpertInfo} from "../models/public_expert_info";
import {PublicUserInfo} from "../models/public_user_info";
import {ExpertSignupProgress} from "../models/expert_signup_progress";
import {StoragePaths} from "../../storage/storage_paths";

export async function createExpertUser({uid}:
  {
    uid: string
  }): Promise<void> {
  const didCreate: boolean = await admin.firestore().runTransaction(async (transaction) => {
    const publicExpertInfoDocRef = getPublicExpertInfoDocumentRef({uid: uid, fromSignUpFlow: true});
    const publicExpertInfoDoc = await transaction.get(publicExpertInfoDocRef);
    if (publicExpertInfoDoc.exists) {
      return false;
    }
    const publicUserInfo: PublicUserInfo = await getPublicUserDocument({transaction: transaction, uid: uid});
    const publicExpertInfo: PublicExpertInfo = {
      "firstName": publicUserInfo.firstName,
      "lastName": publicUserInfo.lastName,
      "description": "",
      "majorExpertCategory": "",
      "minorExpertCategory": "",
      "profilePicUrl": StoragePaths.DEFAULT_PROFILE_PIC_URL,
      "runningSumReviewRatings": 0,
      "numReviews": 0,
      "availability": createDefaultAvailability(),
      "inCall": false,
      "isOnline": true,
    };
    const signUpProgress: ExpertSignupProgress = {
      "updatedProfilePic": false,
      "updatedProfileDescription": false,
      "updatedExpertCategory": false,
      "updatedCallRate": false,
      "updatedAvailability": false,
      "updatedSmsPreferences": false,
    };
    transaction.set(publicExpertInfoDocRef, publicExpertInfo);
    transaction.set(getExpertSignUpProgressDocumentRef({uid: uid}), signUpProgress);
    transaction.set(getExpertRateDocumentRef({expertUid: uid}), createDefaultCallRate());
    return true;
  });
  if (didCreate) {
    Logger.log({
      logName: "createExpertUser", message: `Created expert user ${uid}.`,
      labels: new Map([["expertId", uid]]),
    });
  } else {
    Logger.logError({
      logName: "createExpertUser", message: `User ${uid} is already an expert. Not creating expert user.`,
      labels: new Map([["expertId", uid]]),
    });
  }
}

function createDefaultAvailability() {
  const defaultDayAvailability: DayAvailability = {
    "isAvailable": false,
    "startHourUtc": 0,
    "startMinuteUtc": 0,
    "endHourUtc": 0,
    "endMinuteUtc": 0,
  };
  const defaultWeekAvailability: WeekAvailability = {
    "mondayAvailability": defaultDayAvailability,
    "tuesdayAvailability": defaultDayAvailability,
    "wednesdayAvailability": defaultDayAvailability,
    "thursdayAvailability": defaultDayAvailability,
    "fridayAvailability": defaultDayAvailability,
    "saturdayAvailability": defaultDayAvailability,
    "sundayAvailability": defaultDayAvailability,
  };
  return defaultWeekAvailability;
}

function createDefaultCallRate() {
  const defaultRate: ExpertRate = {
    "centsCallStart": StripeProvider.MIN_BILLABLE_AMOUNT_CENTS,
    "centsPerMinute": 100,
  };
  return defaultRate;
}
