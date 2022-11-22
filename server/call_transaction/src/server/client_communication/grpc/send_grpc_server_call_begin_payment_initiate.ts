import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerCallBeginPaymentInitiate} from "../../../protos/call_transaction_package/ServerCallBeginPaymentInitiate";

export function sendGrpcServerCallBeginPaymentInitiate(clientMessageSender: ClientMessageSenderInterface,
    clientSecret: string, ephemeralKey: string, customerId: string): void {
  const serverCallBeginPaymentInitiate: ServerCallBeginPaymentInitiate = {
    "clientSecret": clientSecret,
    "customerId": customerId,
    "ephemeralKey": ephemeralKey,
  };
  console.log(`Sending ServerCallBeginPaymentInitiate for CustomerId: ${customerId}`);
  clientMessageSender.sendCallBeginPaymentInitiate(serverCallBeginPaymentInitiate);
}
