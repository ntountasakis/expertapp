import {EventSuccessCallback} from "../event_listeners/event_success_callback";
import {PaymentStatus} from "../firebase/firestore/models/payment_status";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {StripePaymentIntentStates} from "../stripe/constants";

export class PaymentStatusState {
    clientMessageSender: ClientMessageSenderInterface;
    paymentSuccessCallback: EventSuccessCallback;

    constructor(sender: ClientMessageSenderInterface, successCallback: EventSuccessCallback) {
      this.clientMessageSender = sender;
      this.paymentSuccessCallback = successCallback;
    }

    onPaymentStatusUpdate(status: PaymentStatus): boolean {
      if (status.status == StripePaymentIntentStates.SUCCEEDED) {
        console.debug("Calling payment success callback");
        this.paymentSuccessCallback(this.clientMessageSender);
        return true;
      }
      return false;
    }
}
