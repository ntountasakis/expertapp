import {TokenMessage} from "firebase-admin/lib/messaging/messaging-api";
import {Logger} from "../google_cloud/google_cloud_logger";
import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";
import {sendFcmMessage} from "../firebase/fcm/sender/fcm_token_sender";
import {convertMillisecondsToMinutesAndSeconds} from "./utils";
import {PrivateUserInfo} from "../firebase/firestore/models/private_user_info";
import {FirebaseDynamicLinkProvider} from "../firebase/dynamic_links/web_api_key";
import {sendSmsMessage} from "../firebase/twilio/sms_sender";

export const sendCallJoinRequestNotification = function({fcmToken, callerUid, calledUid, callTransactionId,
  callRateStartCents, callRatePerMinuteCents, callJoinExpirationTimeUtcMs, callerFirstName,
  calledPrivateUserInfo}: {
    fcmToken: string, callerUid: string, calledUid: string,
    callTransactionId: string, callRateStartCents: string,
    callRatePerMinuteCents: string, callJoinExpirationTimeUtcMs: number,
    callerFirstName: string, calledPrivateUserInfo: PrivateUserInfo,
  }): void {
  sendFcmCallJoinRequestNotification({fcmToken, callerUid, calledUid, callTransactionId,
    callRateStartCents, callRatePerMinuteCents, callJoinExpirationTimeUtcMs, callerFirstName});
  sendSmsCallJoinRequestNotification({fcmToken, callerUid, calledUid, callTransactionId,
    callRateStartCents, callRatePerMinuteCents, callJoinExpirationTimeUtcMs, callerFirstName,
    calledPrivateUserInfo});
};


const sendFcmCallJoinRequestNotification = function({fcmToken, callerUid, calledUid, callTransactionId,
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

const sendSmsCallJoinRequestNotification = async function({fcmToken, callerUid, calledUid, callTransactionId,
  callRateStartCents, callRatePerMinuteCents, callJoinExpirationTimeUtcMs, callerFirstName, calledPrivateUserInfo}: {
    fcmToken: string, callerUid: string, calledUid: string,
    callTransactionId: string, callRateStartCents: string,
    callRatePerMinuteCents: string, callJoinExpirationTimeUtcMs: number,
    callerFirstName: string, calledPrivateUserInfo: PrivateUserInfo,
  }): Promise<void> {
  if (calledPrivateUserInfo.phoneNumber !== "" && calledPrivateUserInfo.consentsToSms) {
    const link: string = await FirebaseDynamicLinkProvider.generateDynamicLinkExpertIncomingCallNotification({
      expertUid: calledUid,
      callerUid: callerUid,
      callTransactionId: callTransactionId,
      callRateStartCents: callRateStartCents,
      callRatePerMinuteCents: callRatePerMinuteCents,
      callJoinExpirationTimeUtcMs: callJoinExpirationTimeUtcMs.toString(),
    });
    const {minutes, seconds} = convertMillisecondsToMinutesAndSeconds(callJoinExpirationTimeUtcMs - Date.now());

    const smsText = "You have an incoming call request from " + callerFirstName +
    ". Click " + link + " to join the call. " + "You have " + minutes + " minutes and " + seconds + " seconds to accept";

    Logger.log({
      logName: Logger.CALL_SERVER, message: `sendSmsCallJoinRequest: : smsText: ${smsText}`,
      labels: new Map([["expertId", calledUid], ["userId", callerUid], ["callTransactionId", callTransactionId], ["fcmToken", fcmToken],
        ["callJoinExpirationTimeUtcMs", callJoinExpirationTimeUtcMs.toString()]]),
    });
    sendSmsMessage({destinationPhoneNumber: calledPrivateUserInfo.phoneNumber, message: smsText});
  }
};
