const accountSid = "AC87274dfdc6bd47f246be01786cb13e9a";
const authToken = "de023d72442b014c47c50a4c81ebff49";
const tollFreeNumber = "+18555592169";

import {Twilio} from "twilio";


export const sendSmsMessage = function({message, destinationPhoneNumber}: {message: string, destinationPhoneNumber: string}): void {
  const client = new Twilio(accountSid, authToken);
  client.messages
      .create({
        body: message,
        from: tollFreeNumber,
        to: destinationPhoneNumber,
      })
      .then((message) => console.log(message.sid));
};
