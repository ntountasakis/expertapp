import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
// eslint-disable-next-line max-len
import {ServerCallTerminatePaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallTerminatePaymentInitiateResolved";

export async function onPaymentSuccessCallTerminate(clientMessageSender: ClientMessageSenderInterface): Promise<void> {
  const paymentResolved: ServerCallTerminatePaymentInitiateResolved = {};
  console.log("On paymentSuccessCallTerminate. Sending payment resolved to client");
  clientMessageSender.sendCallTerminatePaymentInitiateResolved(paymentResolved);
}
