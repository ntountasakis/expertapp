import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
// eslint-disable-next-line max-len
import {ServerCallBeginPaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";

export async function onPaymentSuccessCallInitiate(clientMessageSender: ClientMessageSenderInterface): Promise<void> {
  const paymentResolved: ServerCallBeginPaymentInitiateResolved = {};
  clientMessageSender.sendCallBeginPaymentInitiateResolved(paymentResolved);
}
