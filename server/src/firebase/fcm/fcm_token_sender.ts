import * as admin from "firebase-admin";
import {CallJoinRequest} from "./messages/call_join_request";

export const sendCallJoinRequest = function(token: string, joinRequest: CallJoinRequest,
    callTransactionId: string): void {
  const payload = {
    data: {
      messageType: joinRequest.messageType(),
      callerUid: joinRequest.callerUid,
      calledUid: joinRequest.calledUid,
      callTransactionId: callTransactionId,
    },
    token: token,
  };

  // Send a message to the device corresponding to the provided
  // registration token.


  admin.messaging().send(payload)
      .then((response: any) => {
        // Response is a message ID string.
        console.log("Successfully sent message:", response);
      })
      .catch((error: any) => {
        console.log("Error sending message:", error);
      });
};
