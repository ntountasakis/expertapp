
import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
// eslint-disable-next-line max-len
import {ServerCallTerminatePaymentInitiate} from "../../../protos/call_transaction_package/ServerCallTerminatePaymentInitiate";

export function sendGrpcServerCallTerminatePaymentInitiate({clientMessageSender, clientSecret, customerId}:
    {clientMessageSender: ClientMessageSenderInterface,
    clientSecret: string, customerId: string}): void {
  const serverCallTerminatePaymentInitiate: ServerCallTerminatePaymentInitiate = {
    "clientSecret": clientSecret,
    "customerId": customerId,
  };
  console.log(`Sending ServerCallTerminatePaymentInitiate for CustomerId: ${customerId} ClientSecret: ${clientSecret}`);
  clientMessageSender.sendCallTerminatePaymentInitiate(serverCallTerminatePaymentInitiate);
}