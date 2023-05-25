import {TokenMessage} from "firebase-admin/lib/messaging/messaging-api";
import {Logger} from "../../../google_cloud/google_cloud_logger";
import {CallJoinCancel} from "../messages/call_join_cancel";
import {CallJoinRequest} from "../messages/call_join_request";
import {sendFcmMessage} from "../sender/fcm_token_sender";
import {convertMillisecondsToMinutesAndSeconds} from "../../../general/utils";

export const sendFcmCallJoinRequest = function({fcmToken, callerUid, calledUid, callTransactionId,
  callRateStartCents, callRatePerMinuteCents, callJoinExpirationTimeUtcMs, callerFirstName}: {
    fcmToken: string, callerUid: string, calledUid: string,
    callTransactionId: string, callRateStartCents: string,
    callRatePerMinuteCents: string, callJoinExpirationTimeUtcMs: number,
    callerFirstName: string,
  }): void {
  const {minutes, seconds} = convertMillisecondsToMinutesAndSeconds(callJoinExpirationTimeUtcMs - Date.now());
  const payload: TokenMessage = {
    data: {
      messageType: CallJoinRequest.messageType(),
      callerUid: callerUid,
      calledUid: calledUid,
      callTransactionId: callTransactionId,
      callRateStartCents: callRateStartCents,
      callRatePerMinuteCents: callRatePerMinuteCents,
      callJoinExpirationTimeUtcMs: callJoinExpirationTimeUtcMs.toString(),
    },
    token: fcmToken,
    notification: {
      title: "Incoming call from " + callerFirstName,
      body: "You have " + minutes + " minutes and " + seconds + " seconds to accept the call.",
    },
  };

  // Send a message to the device corresponding to the provided registration token.
  Logger.log({
    logName: Logger.CALL_SERVER, message: `sendFcmCallJoinRequest: payload: ${JSON.stringify(payload)}`,
    labels: new Map([["expertId", calledUid], ["userId", callerUid], ["callTransactionId", callTransactionId], ["fcmToken", fcmToken],
      ["callJoinExpirationTimeUtcMs", callJoinExpirationTimeUtcMs.toString()]]),
  });
  sendFcmMessage(payload);
};

export const sendFcmCallJoinCancel = function({fcmToken}: { fcmToken: string }): void {
  const payload = {
    data: {
      messageType: CallJoinCancel.messageType(),
    },
    token: fcmToken,
  };

  // Send a message to the device corresponding to the provided registration token.
  Logger.log({
    logName: Logger.CALL_SERVER, message: `sendFcmCallJoinCancel: payload: ${JSON.stringify(payload)}`,
    labels: new Map([["fcmToken", fcmToken]]),
  });
  sendFcmMessage(payload);
};
