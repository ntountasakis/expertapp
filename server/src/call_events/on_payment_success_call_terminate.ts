import {BaseCallState} from "../call_state/common/base_call_state";
import {PaymentStatus} from "../firebase/firestore/models/payment_status";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
// eslint-disable-next-line max-len
import {ServerCallTerminatePaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallTerminatePaymentInitiateResolved";
import {StripePaymentIntentStates} from "../stripe/constants";

export function onPaymentSuccessCallTerminate(clientMessageSender: ClientMessageSenderInterface,
    callState : BaseCallState, update: PaymentStatus): boolean {
  if (update.status == StripePaymentIntentStates.SUCCEEDED) {
    const paymentResolved: ServerCallTerminatePaymentInitiateResolved = {};
    console.log("On paymentSuccessCallTerminate. Sending payment resolved to client");
    clientMessageSender.sendCallTerminatePaymentInitiateResolved(paymentResolved);
    return true;
  }
  return false;
}
