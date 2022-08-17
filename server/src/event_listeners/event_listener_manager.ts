import {PaymentStatusState} from "../call_state/payment_status_state";
import {PaymentStatus} from "../firebase/firestore/models/payment_status";
import {listenForPaymentStatusUpdates} from "../stripe/listen_for_payment_status_updates";

interface Unsubscribe
{
    (): void;
}

export class EventListenerManager {
    paymentStatusListeners = new Map<string, PaymentStatusState>();

    registerForPaymentStatusUpdates(paymentStatusId: string, paymentStatusState: PaymentStatusState): void {
      this.paymentStatusListeners.set(paymentStatusId, paymentStatusState);
      listenForPaymentStatusUpdates(paymentStatusId, this);
    }

    onPaymentStatusUpdate(paymentStatusId: string, update: PaymentStatus, unsubscribeFn: Unsubscribe): void {
      if (!this.paymentStatusListeners.has(paymentStatusId)) {
        console.warn(`EventListenerManager. PaymentStatusUpdate for Id: ${paymentStatusId} but no listeners`);
        return;
      }
      const callback = this.paymentStatusListeners.get(paymentStatusId);
      const paymentStatusState = callback as PaymentStatusState;
      const isDone = paymentStatusState.onPaymentStatusUpdate(update);

      if (isDone) {
        this.paymentStatusListeners.delete(paymentStatusId);
        unsubscribeFn();
      }
    }
}
