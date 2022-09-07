import * as admin from "firebase-admin";
import {Message} from "firebase-admin/lib/messaging/messaging-api";

export const sendFcmMessage = function(payload: Message): void {
  admin.messaging().send(payload)
      .then((response: any) => {
        // Response is a message ID string.
        console.log("Successfully sent message:", response);
      })
      .catch((error: any) => {
        console.log("Error sending message:", error);
      });
};
