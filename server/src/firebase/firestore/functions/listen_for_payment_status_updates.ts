import * as admin from "firebase-admin";
import {EventListenerManager} from "../../../event_listeners/event_listener_manager";
import {EventUnsubscribeInterface} from "../../../event_listeners/event_unsubscribe_interface";
import {PaymentStatus} from "../models/payment_status";

export function listenForPaymentStatusUpdates(
    paymentStatusId: string, listenerManager: EventListenerManager): EventUnsubscribeInterface {
  const doc = admin.firestore().collection("payment_statuses").doc(paymentStatusId);
  const unsubscribeFn = doc.onSnapshot((docSnapshot) => {
    const paymentStatus = docSnapshot.data() as PaymentStatus;
    console.log(`On payment status update. PaymentStatusId: ${paymentStatusId} 
      Uid: ${paymentStatus.uid} Status: ${paymentStatus.status} 
      CentsToCollect: ${paymentStatus.centsToCollect} CentsCollected: ${paymentStatus.centsCollected}`);
    listenerManager.onPaymentStatusUpdate(docSnapshot.id, paymentStatus);
  }, (err) => {
    console.log(`Encountered error: ${err}`);
  });

  return unsubscribeFn;
}
