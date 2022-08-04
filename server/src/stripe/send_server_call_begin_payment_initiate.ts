import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ServerCallBeginPaymentInitiate} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiate";

export function sendServerCallBeginPaymentInitiate(clientMessageSender: ClientMessageSenderInterface,
    clientSecret: string, customerId: string): void {
  const serverCallBeginPaymentInitiate: ServerCallBeginPaymentInitiate = {
    "clientSecret": clientSecret,
    "customerId": customerId,
  };
  console.log(`Sending ServerCallBeginPaymentInitiate for CustomerId: ${customerId} ClientSecret: ${clientSecret}`);
  clientMessageSender.sendCallBeginPaymentInitiate(serverCallBeginPaymentInitiate);
}
