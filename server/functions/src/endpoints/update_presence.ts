import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getStatusDocumentRef, getPublicExpertInfoDocumentRef} from "../shared/src/firebase/firestore/document_fetchers/fetchers";
import {PublicExpertInfo} from "../shared/src/firebase/firestore/models/public_expert_info";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";

// taken from https://firebase.google.com/docs/firestore/solutions/presence

export const updatePresence = functions.database.ref("/status/{uid}").onUpdate(async (change, context) => {
  // Get the data written to Realtime Database
  const eventStatus = change.after.val();

  // Then use other event data to create a reference to the
  // corresponding Firestore document.
  const userStatusFirestoreRef = getStatusDocumentRef({uid: context.params.uid});

  // It is likely that the Realtime Database change that triggered
  // this event has already been overwritten by a fast change in
  // online / offline status, so we'll re-read the current data
  // and compare the timestamps.
  const statusSnapshot = await change.after.ref.once("value");
  const status = statusSnapshot.val();

  // If the current timestamp for this data is newer than
  // the data that triggered this event, we exit this function.
  if (status.lastChanged > eventStatus.lastChanged) {
    Logger.log({
      logName: "updatePresence", message: `Presence not updated for ${context.params.uid} because \
      it was overwritten by a newer event. Status: ${JSON.stringify(status)} Event status: ${JSON.stringify(eventStatus)}`,
      labels: new Map([["userId", context.params.uid]]),
    });
    return;
  }

  const isOnline = eventStatus.presence == "online";
  await admin.firestore().runTransaction(async (transaction) => {
    const publicExpertInfoDocRef = getPublicExpertInfoDocumentRef({uid: context.params.uid, fromSignUpFlow: false});
    const publicExpertInfoDoc = await transaction.get(publicExpertInfoDocRef);
    if (!publicExpertInfoDoc.exists) {
      return;
    }
    const info = publicExpertInfoDoc.data() as PublicExpertInfo;
    if (info.isOnline != isOnline) {
      transaction.update(publicExpertInfoDocRef, {
        "isOnline": isOnline,
      });
      Logger.log({
        logName: "updatePresence", message: `Expert presence updated for ${context.params.uid}. IsOnline: ${isOnline}`,
        labels: new Map([["expertId", context.params.uid]]),
      });
    }
  });


  // Otherwise, we convert the last_changed field to a Date
  eventStatus.lastChanged = new Date(eventStatus.lastChanged);

  // ... and write it to Firestore.
  await userStatusFirestoreRef.set(eventStatus);

  Logger.log({
    logName: "updatePresence", message: `Presence updated for ${context.params.uid}. \
    Status: ${JSON.stringify(status)} Event status: ${JSON.stringify(eventStatus)}`,
    labels: new Map([["userId", context.params.uid]]),
  });
});
