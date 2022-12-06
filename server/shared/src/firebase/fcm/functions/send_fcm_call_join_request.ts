import { CallJoinRequest } from "../messages/call_join_request";
import { sendFcmMessage } from "../sender/fcm_token_sender";

export const sendFcmCallJoinRequest = function ({ fcmToken, callerUid, calledUid, callTransactionId, callRateStartCents, callRatePerMinuteCents }: {
  fcmToken: string, callerUid: string, calledUid: string,
  callTransactionId: string, callRateStartCents: string,
  callRatePerMinuteCents: string,
}): void {
  const payload = {
    data: {
      messageType: CallJoinRequest.messageType(),
      callerUid: callerUid,
      calledUid: calledUid,
      callTransactionId: callTransactionId,
      callRateStartCents: callRateStartCents,
      callRatePerMinuteCents: callRatePerMinuteCents,
    },
    token: fcmToken,
  };

  // Send a message to the device corresponding to the provided registration token.
  sendFcmMessage(payload);
};
