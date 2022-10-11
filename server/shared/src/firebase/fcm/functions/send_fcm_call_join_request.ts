import {CallJoinRequest} from "../messages/call_join_request";
import {sendFcmMessage} from "../sender/fcm_token_sender";

export const sendFcmCallJoinRequest = function(fcmToken: string, joinRequest: CallJoinRequest,
    callTransactionId: string): void {
  const payload = {
    data: {
      messageType: joinRequest.messageType(),
      callerUid: joinRequest.callerUid,
      calledUid: joinRequest.calledUid,
      callTransactionId: callTransactionId,
    },
    token: fcmToken,
  };

  // Send a message to the device corresponding to the provided registration token.
  sendFcmMessage(payload);
};
