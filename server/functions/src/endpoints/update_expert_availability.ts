import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";
import {FirebaseDocRef, getExpertInfoConditionalOnSignup} from "../shared/src/firebase/firestore/functions/expert_info_conditional_sign_up_fetcher";
import {WeekAvailability} from "../shared/src/firebase/firestore/models/expert_availability";
import {expertAvailabilitySchemaValidator} from "../shared/src/json_schema/expert_availability_validator.js";


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
  const isValid = expertAvailabilitySchemaValidator(payload);
  if (!isValid) {
    Logger.logError({
      logName: "updateExpertAvailability", message: `Cannot update availability because payload is invalid. Payload: ${payload}`,
      labels: new Map([["expertId", uid], ["version", version]]),
    });
  }
  return isValid;
}

function updateAvailabilityProgress(signupProgressDocRef: FirebaseDocRef, transaction: FirebaseFirestore.Transaction) {
  if (signupProgressDocRef == null) {
    throw new Error("Cannot update availability because signup progress doc ref is null");
  }
  transaction.update(signupProgressDocRef, {
    "updatedAvailability": true,
  });
}

function updateAvailabilityInfo(expertInfoRef: FirebaseDocRef, transaction: FirebaseFirestore.Transaction, newAvailability: WeekAvailability) {
  if (expertInfoRef == null) {
    throw new Error("Cannot update availability because expert info ref is null");
  }
  transaction.update(expertInfoRef, {
    "availability": newAvailability,
  });
}

async function updateAvailability(uid: string, version: string, fromSignUpFlow: boolean, payload: Map<string, unknown>): Promise<boolean> {
  const result = JSON.parse(JSON.stringify(payload)) as WeekAvailability;
  const value = await admin.firestore().runTransaction(async (transaction) => {
    const success: boolean = await getExpertInfoConditionalOnSignup({functionNameForLogging: "updateExpertAvailability",
      uid: uid, fromSignUpFlow: fromSignUpFlow,
      transaction: transaction, version: version, updateSignupProgressFunc: updateAvailabilityProgress,
      updateExpertInfoFunc: updateAvailabilityInfo,
      contextData: result,
    });
    if (success) {
      Logger.log({
        logName: "updateExpertAvailability", message: `Updated availability for ${uid}. New availability: ${result}. From sign up flow: ${fromSignUpFlow}`,
        labels: new Map([["expertId", uid], ["version", version]]),
      });
    }
    return success;
  });
  return value;
}
