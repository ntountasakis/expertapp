import {EventSuccessCallback} from "../event_listeners/event_success_callback";
import {PaymentStatus} from "../firebase/firestore/models/payment_status";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {StripePaymentIntentStates} from "../stripe/constants";
import {ClientCallState} from "./client_call_state";

export class PaymentStatusState {
    clientMessageSender: ClientMessageSenderInterface;
    clientCallState: ClientCallState;
    paymentSuccessCallback: EventSuccessCallback;

    constructor(sender: ClientMessageSenderInterface,
        clientCallState: ClientCallState,
        successCallback: EventSuccessCallback) {
      this.clientMessageSender = sender;
      this.paymentSuccessCallback = successCallback;
      this.clientCallState = clientCallState;
    }

    onPaymentStatusUpdate(status: PaymentStatus): boolean {
      if (status.status == StripePaymentIntentStates.SUCCEEDED) {
        this.paymentSuccessCallback(this.clientMessageSender, this.clientCallState);
        return true;
      }
      return false;
    }
}
