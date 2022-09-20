import * as admin from "firebase-admin";
import {FirestoreListenerManager} from "../event_listeners/firestore_listener_manager";
import {FirestoreUnsubscribeInterface} from "../event_listeners/firestore_unsubscribe_interface";
import {PaymentStatus} from "../models/payment_status";

export function listenForPaymentStatusUpdates(
    paymentStatusId: string, listenerManager: FirestoreListenerManager): FirestoreUnsubscribeInterface {
  const doc = admin.firestore().collection("payment_statuses").doc(paymentStatusId);
  const unsubscribeFn = doc.onSnapshot((docSnapshot) => {
    const paymentStatus = docSnapshot.data() as PaymentStatus;
    console.log(`On payment status update. PaymentStatusId: ${paymentStatusId} 
      Uid: ${paymentStatus.uid} Status: ${paymentStatus.status} 
      CentsToCollect: ${paymentStatus.centsToCollect} CentsCollected: ${paymentStatus.centsCollected}`);
    listenerManager.onEventUpdate({key: docSnapshot.id, type: "PaymentStatus", update: paymentStatus});
  }, (err) => {
    console.log(`Encountered error: ${err}`);
  });

  return unsubscribeFn;
}
