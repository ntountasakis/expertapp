import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import Ajv, { JTDSchemaType } from "ajv/dist/jtd";
import { DayAvailability, WeekAvailability } from "../../../shared/src/firebase/firestore/models/expert_availability";
import { getExpertSignUpProgressDocumentRef, getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";


export const updateExpertAvailability = functions.https.onCall(async (data, context) => {
  if (context.auth == null || context.auth.uid == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const fromSignUpFlow = data.fromSignUpFlow;
  const availability = data.availability;
  const version = data.version;
  if (availability == null) {
    throw new Error("Cannot update expert rate with null payload");
  }
  if (fromSignUpFlow == null) {
    throw new Error("Cannot update expert rate with null fromSignUpFlow");
  }
  if (version == null) {
    throw new Error("Cannot update expert rate with null version");
  }

  const isPayloadValid = validatePayload(context.auth.uid, version, availability);
  if (!isPayloadValid) {
    return {
      success: false,
      message: "Please contact customer service. We are experiencing technical difficulties",
    };
  }
  const success = await updateAvailability(context.auth.uid, version, fromSignUpFlow, availability);
  return {
    success: success,
    message: success ? "Your availability was updated successfully" : "Internal Server Error",
  };
});


function validatePayload(uid: string, version: string, payload: Map<string, unknown>): boolean {
  const ajv = new Ajv();
  const validator = ajv.compile(WeekAvailabilitySchema);
  const isValid = validator(payload);
  if (!isValid) {
    Logger.logError({
      logName: "updateExpertAvailability", message: `Cannot update availability because payload is invalid. Payload: ${payload}`,
      labels: new Map([["expertId", uid], ["version", version]]),
    });
  }
  return isValid;
}

async function updateAvailability(uid: string, version: string, fromSignUpFlow: boolean, payload: Map<string, unknown>): Promise<boolean> {
  const ajv = new Ajv();
  const parser = ajv.compileParser(WeekAvailabilitySchema);
  const result = parser(JSON.stringify(payload)) as WeekAvailability;
  return await admin.firestore().runTransaction(async (transaction) => {
    const expertSignUpProgressDocRef = getExpertSignUpProgressDocumentRef({ uid: uid });
    const expertSignUpProgressDoc = fromSignUpFlow ? await transaction.get(expertSignUpProgressDocRef) : null;
    const publicExpertInfoDocRef = getPublicExpertInfoDocumentRef({ uid: uid, fromSignUpFlow: fromSignUpFlow });
    const publicExpertInfoDoc = await transaction.get(publicExpertInfoDocRef);
    if (!publicExpertInfoDoc.exists) {
      Logger.logError({
        logName: "updateExpertAvailability", message: `Cannot update availability for ${uid} because they are not a expert.`,
        labels: new Map([["expertId", uid], ["version", version]]),
      });
      return false;
    }
    if (fromSignUpFlow && !(expertSignUpProgressDoc!.exists)) {
      Logger.logError({
        logName: "updateExpertAvailability", message: `Cannot update availability for ${uid} because they have no sign up progress document.`,
        labels: new Map([["expertId", uid], ["version", version]])
      });
      return false;
    }
    if (fromSignUpFlow) {
      transaction.update(expertSignUpProgressDocRef, {
        "updatedAvailability": true,
      });
    }
    transaction.update(publicExpertInfoDocRef, {
      "availability": result,
    });
    Logger.log({
      logName: "updateExpertAvailability", message: `Updated availability for ${uid}. New availability: ${result}. From sign up flow: ${fromSignUpFlow}`,
      labels: new Map([["expertId", uid], ["version", version]]),
    });
    return true;
  });
}

const WeekAvailabilitySchema: JTDSchemaType<WeekAvailability, { DayAvailabilitySchema: DayAvailability }> = {
  definitions: {
    DayAvailabilitySchema: {
      properties: {
        isAvailable: { type: "boolean" },
        startHourUtc: { type: "int32" },
        startMinuteUtc: { type: "int32" },
        endHourUtc: { type: "int32" },
        endMinuteUtc: { type: "int32" },
      },
    },
  },
  properties: {
    mondayAvailability: { ref: "DayAvailabilitySchema" },
    tuesdayAvailability: { ref: "DayAvailabilitySchema" },
    wednesdayAvailability: { ref: "DayAvailabilitySchema" },
    thursdayAvailability: { ref: "DayAvailabilitySchema" },
    fridayAvailability: { ref: "DayAvailabilitySchema" },
    saturdayAvailability: { ref: "DayAvailabilitySchema" },
    sundayAvailability: { ref: "DayAvailabilitySchema" },
  },
};
