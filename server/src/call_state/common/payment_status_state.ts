import {EventSuccessCallback} from "../../event_listeners/event_success_callback";
import {PaymentStatus} from "../../firebase/firestore/models/payment_status";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {StripePaymentIntentStates} from "../../stripe/constants";
import {BaseCallState} from "./base_call_state";

export class PaymentStatusState {
    clientMessageSender: ClientMessageSenderInterface;
    callState: BaseCallState;
    paymentSuccessCallback: EventSuccessCallback;

    constructor(sender: ClientMessageSenderInterface,
        callState: BaseCallState,
        successCallback: EventSuccessCallback) {
      this.clientMessageSender = sender;
      this.paymentSuccessCallback = successCallback;
      this.callState = callState;
    }

    onPaymentStatusUpdate(status: PaymentStatus): boolean {
      if (status.status == StripePaymentIntentStates.SUCCEEDED) {
        this.paymentSuccessCallback(this.clientMessageSender, this.callState);
        return true;
      }
      return false;
    }
}
