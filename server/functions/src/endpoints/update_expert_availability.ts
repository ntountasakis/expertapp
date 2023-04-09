import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import Ajv, { JTDSchemaType } from "ajv/dist/jtd";
import { DayAvailability, WeekAvailability } from "../../../shared/src/firebase/firestore/models/expert_availability";
import { getPublicExpertInfoDocumentRef } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";


export const updateExpertAvailability = functions.https.onCall(async (data, context) => {
  if (context.auth == null || context.auth.uid == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const isPayloadValid = validatePayload(data);
  if (!isPayloadValid) {
    return {
      success: false,
      message: "Please contact customer service. We are experiencing technical difficulties",
    };
  }
  const success = await updateAvailability(context.auth.uid, data);
  return {
    success: success,
    message: success ? "Your availability was updated successfully" : "Internal Server Error",
  };
});


function validatePayload(payload: Map<string, unknown>): boolean {
  const ajv = new Ajv();
  const validator = ajv.compile(WeekAvailabilitySchema);
  const isValid = validator(payload);
  if (!isValid) {
    console.error(validator.errors);
  }
  return isValid;
}

async function updateAvailability(uid: string, payload: Map<string, unknown>): Promise<boolean> {
  const ajv = new Ajv();
  const parser = ajv.compileParser(WeekAvailabilitySchema);
  const result = parser(JSON.stringify(payload)) as WeekAvailability;
  return await admin.firestore().runTransaction(async (transaction) => {
    const docRef = getPublicExpertInfoDocumentRef({ uid: uid });
    const publicExpertInfoDoc = await transaction.get(docRef);
    if (!publicExpertInfoDoc.exists) {
      Logger.logError({
        logName: "updateExpertAvailability", message: `Cannot update availability for ${uid} because they are not a expert.`,
        labels: new Map([["expertId", uid]]),
      });
      return false;
    }
    transaction.update(getPublicExpertInfoDocumentRef({ uid: uid }), {
      "availability": result,
    });
    Logger.log({
      logName: "updateExpertAvailability", message: `Updated availability for ${uid}. New availability: ${result}`,
      labels: new Map([["expertId", uid]]),
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
