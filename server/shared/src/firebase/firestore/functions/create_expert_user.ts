import * as admin from "firebase-admin";
import { getExpertRateDocumentRef, getPrivateUserDocumentRef, getPublicExpertInfoDocumentRef } from "../document_fetchers/fetchers";
import { DayAvailability, WeekAvailability } from "../models/expert_availability";
import { ExpertRate } from "../models/expert_rate";
import { PrivateUserInfo } from "../models/private_user_info";
import { PublicExpertInfo } from "../models/public_expert_info";

export async function createExpertUser({ uid, firstName, lastName, email, profilePicUrl, stripeCustomerId }:
  {
    uid: string, firstName: string, lastName: string, email: string,
    profilePicUrl: string, stripeCustomerId: string
  }): Promise<void> {
  const privateUserInfo: PrivateUserInfo = {
    "email": email,
    "stripeCustomerId": stripeCustomerId,
    "stripeConnectedId": "acct_1LmpLYPKLydnyIBv" // TODO: Remove this hard-coded value
  };
  const publicExpertInfo: PublicExpertInfo = {
    "firstName": firstName,
    "lastName": lastName,
    "description": "",
    "profilePicUrl": profilePicUrl,
    "runningSumReviewRatings": 0,
    "numReviews": 0,
    "availability": createDefaultAvailability(),
    "inCall": false,
  };
  await admin.firestore().runTransaction(async (transaction) => {
    transaction.set(getPrivateUserDocumentRef({ uid: uid }), privateUserInfo);
    transaction.set(getPublicExpertInfoDocumentRef({ uid: uid }), publicExpertInfo);
    transaction.set(getExpertRateDocumentRef({ expertUid: uid }), createDefaultCallRate());
  });
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
  }
  return defaultWeekAvailability;
}

function createDefaultCallRate() {
  const defaultRate: ExpertRate = {
    "centsCallStart": 100,
    "centsPerMinute": 100,
  };
  return defaultRate;
}