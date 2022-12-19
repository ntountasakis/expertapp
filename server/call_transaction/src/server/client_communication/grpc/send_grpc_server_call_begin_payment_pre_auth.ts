import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerCallBeginPaymentPreAuth} from "../../../protos/call_transaction_package/ServerCallBeginPaymentPreAuth";

export function sendGrpcServerCallBeginPaymentInitiate(clientMessageSender: ClientMessageSenderInterface,
    clientSecret: string, ephemeralKey: string, customerId: string): void {
  const serverCallBeginPaymentInitiate: ServerCallBeginPaymentPreAuth = {
    "clientSecret": clientSecret,
    "customerId": customerId,
    "ephemeralKey": ephemeralKey,
  };
  console.log(`Sending ServerCallBeginPaymentPreAuth for CustomerId: ${customerId}`);
  clientMessageSender.sendCallBeginPaymentPreAuth(serverCallBeginPaymentInitiate);
}
