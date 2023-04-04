import { CallJoinCancel } from "../messages/call_join_cancel";
import { CallJoinRequest } from "../messages/call_join_request";
import { sendFcmMessage } from "../sender/fcm_token_sender";

export const sendFcmCallJoinRequest = function ({ fcmToken, callerUid, calledUid, callTransactionId,
  callRateStartCents, callRatePerMinuteCents, callJoinExpirationTimeUtcMs }: {
    fcmToken: string, callerUid: string, calledUid: string,
    callTransactionId: string, callRateStartCents: string,
    callRatePerMinuteCents: string, callJoinExpirationTimeUtcMs: number,
  }): void {
  const payload = {
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
  };

  // Send a message to the device corresponding to the provided registration token.
  console.log("sendFcmCallJoinRequest: payload: " + JSON.stringify(payload));
  sendFcmMessage(payload);
};

export const sendFcmCallJoinCancel = function ({ fcmToken }: { fcmToken: string }): void {
  const payload = {
    data: {
      messageType: CallJoinCancel.messageType(),
    },
    token: fcmToken,
  };

  // Send a message to the device corresponding to the provided registration token.
  console.log("sendFcmCallJoinCancel: payload: " + JSON.stringify(payload));
  sendFcmMessage(payload);
};
