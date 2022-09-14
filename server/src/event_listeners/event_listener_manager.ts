import {PaymentStatusState} from "../call_state/payment_status_state";
import {PaymentStatus} from "../firebase/firestore/models/payment_status";
import {listenForPaymentStatusUpdates} from "../firebase/firestore/functions/listen_for_payment_status_updates";
import {EventUnsubscribeInterface} from "./event_unsubscribe_interface";

export class EventListenerManager {
    paymentStatusListeners = new Map<string, [PaymentStatusState, EventUnsubscribeInterface]>();

    clear(): void {
      this.paymentStatusListeners.forEach((value: [PaymentStatusState, EventUnsubscribeInterface], key: string) => {
        const unsubscribeFn = value[1];
        console.log(`Unsubscribing from PaymentStatusId: ${key}`);
        unsubscribeFn();
      });
    }

    registerForPaymentStatusUpdates(paymentStatusId: string, paymentStatusState: PaymentStatusState): void {
      const unsubscribeFn = listenForPaymentStatusUpdates(paymentStatusId, this);
      this.paymentStatusListeners.set(paymentStatusId, [paymentStatusState, unsubscribeFn]);
    }

    onPaymentStatusUpdate(paymentStatusId: string, update: PaymentStatus): void {
      const paymentStatusListener : [PaymentStatusState, EventUnsubscribeInterface] | undefined =
        this.paymentStatusListeners.get(paymentStatusId);

      if (paymentStatusListener === undefined) {
        console.warn(`EventListenerManager. PaymentStatusUpdate for Id: ${paymentStatusId} but no listeners`);
        return;
      }

      const paymentStatusState = paymentStatusListener[0];
      const unsubscribeFn = paymentStatusListener[1];

      const isDone = paymentStatusState.onPaymentStatusUpdate(update);

      if (isDone) {
        this.paymentStatusListeners.delete(paymentStatusId);
        unsubscribeFn();
      }
    }
}
