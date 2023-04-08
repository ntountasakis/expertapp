import * as admin from "firebase-admin";
import { Logger } from "../../../google_cloud/google_cloud_logger";
import { StripeProvider } from "../../../stripe/stripe_provider";
import { getExpertRateDocumentRef, getPublicExpertInfoDocumentRef, getPublicUserDocument } from "../document_fetchers/fetchers";
import { DayAvailability, WeekAvailability } from "../models/expert_availability";
import { ExpertRate } from "../models/expert_rate";
import { PublicExpertInfo } from "../models/public_expert_info";
import { PublicUserInfo } from "../models/public_user_info";

export async function createExpertUser({ uid, profileDescription, profilePicUrl, majorExpertCategory, minorExpertCategory }:
  {
    uid: string, profilePicUrl: string, profileDescription: string, majorExpertCategory: string, minorExpertCategory: string
  }): Promise<void> {
  const didCreate: boolean = await admin.firestore().runTransaction(async (transaction) => {
    const doc = await getPublicExpertInfoDocumentRef({ uid: uid }).get();
    if (doc.exists) {
      return false;
    }
    const publicUserInfo: PublicUserInfo = await getPublicUserDocument({ transaction: transaction, uid: uid });
    const publicExpertInfo: PublicExpertInfo = {
      "firstName": publicUserInfo.firstName,
      "lastName": publicUserInfo.lastName,
      "description": profileDescription,
      "majorExpertCategory": majorExpertCategory,
      "minorExpertCategory": minorExpertCategory,
      "profilePicUrl": profilePicUrl,
      "runningSumReviewRatings": 0,
      "numReviews": 0,
      "availability": createDefaultAvailability(),
      "inCall": false,
    };
    transaction.set(getPublicExpertInfoDocumentRef({ uid: uid }), publicExpertInfo);
    transaction.set(getExpertRateDocumentRef({ expertUid: uid }), createDefaultCallRate());
    return true;
  });
  if (didCreate) {
    Logger.log({
      logName: "createExpertUser", message: `Created expert user ${uid}.`,
      labels: new Map([["expertId", uid]])
    });
  } else {
    Logger.logError({
      logName: "createExpertUser", message: `User ${uid} is already an expert. Not creating expert user.`,
      labels: new Map([["expertId", uid]])
    });
  }
}

function createDefaultAvailability() {
  const defaultDayAvailability: DayAvailability = {
    "isAvailable": true,
    "startHourUtc": 0,
    "startMinuteUtc": 0,
    "endHourUtc": 23,
    "endMinuteUtc": 59,
  };
  const defaultWeekAvailability: WeekAvailability = {
    "mondayAvailability": defaultDayAvailability,
    "tuesdayAvailability": defaultDayAvailability,
    "wednesdayAvailability": defaultDayAvailability,
    "thursdayAvailability": defaultDayAvailability,
    "fridayAvailability": defaultDayAvailability,
    "saturdayAvailability": defaultDayAvailability,
    "sundayAvailability": defaultDayAvailability,
  }
  return defaultWeekAvailability;
}

function createDefaultCallRate() {
  const defaultRate: ExpertRate = {
    "centsCallStart": StripeProvider.MIN_BILLABLE_AMOUNT_CENTS,
    "centsPerMinute": 100,
  };
  return defaultRate;
}