import * as admin from "firebase-admin";
import { Message } from "firebase-admin/lib/messaging/messaging-api";
import { Logger } from "../../../google_cloud/google_cloud_logger";

export const sendFcmMessage = function (payload: Message): void {
  admin.messaging().send(payload)
    .then((response: any) => {
      // Response is a message ID string.
      Logger.log({
        logName: Logger.CALL_SERVER, message: `Successfully sent message: ${response}`,
      });
    })
    .catch((error: any) => {
      Logger.logError({
        logName: Logger.CALL_SERVER, message: `Error sending message: ${error}`,
      });
    });
};
