import * as functions from "firebase-functions";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";
export const twilioWebhookSmsStatus = functions.https.onRequest(async (request, response) => {
  const messageSid = request.body.MessageSid;
  const messageStatus = request.body.MessageStatus;
  const fromNumber = request.body.From;
  Logger.log({
    logName: "twilioWebhookSmsStatus", message: `Sms status: ${messageStatus}`,
    labels: new Map([["messageSid", messageSid], ["messageStatus", messageStatus], ["fromNumber", fromNumber]]),
  });
  response.status(200).end();
});
