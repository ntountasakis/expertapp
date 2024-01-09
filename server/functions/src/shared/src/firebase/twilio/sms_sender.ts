import {Twilio} from "twilio";
import {SmsConfig} from "./sms_config";

export const sendSmsMessage = async function({message, destinationPhoneNumber}:
  {message: string, destinationPhoneNumber: string}): Promise<string> {
  const client = new Twilio(SmsConfig.ACCOUNT_SID, SmsConfig.AUTH_TOKEN);
  const result = await client.messages
      .create({
        body: message,
        from: SmsConfig.SEND_NUMBER,
        to: destinationPhoneNumber,
        statusCallback: SmsConfig.STATUS_CALLBACK_URL,
      });
  return result.sid;
};
