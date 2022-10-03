import { PaymentStatus } from "../../../../shared/firebase/firestore/models/payment_status";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

import {ServerCallTerminatePaymentInitiateResolved} from "../../protos/call_transaction_package/ServerCallTerminatePaymentInitiateResolved";

import {StripePaymentIntentStates} from "../../stripe/constants";

export function onCallerPaymentSuccessCallTerminate(clientMessageSender: ClientMessageSenderInterface,
    callState : BaseCallState, update: PaymentStatus): Promise<boolean> {
  if (update.status == StripePaymentIntentStates.SUCCEEDED) {
    const paymentResolved: ServerCallTerminatePaymentInitiateResolved = {};
    console.log("On paymentSuccessCallTerminate. Sending payment resolved to client");
    clientMessageSender.sendCallTerminatePaymentInitiateResolved(paymentResolved);
    return Promise.resolve(true);
  }
  return Promise.resolve(false);
}
