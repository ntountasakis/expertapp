import {getPaymentStatusDocumentRef} from "../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {PaymentStatus} from "../../../../../../shared/src/firebase/firestore/models/payment_status";
import {FirestoreListenerManager} from "../firestore_listener_manager";
import {FirestoreUnsubscribeInterface} from "../firestore_unsubscribe_interface";

export function listenForPaymentStatusUpdates(
    paymentStatusId: string, listenerManager: FirestoreListenerManager): FirestoreUnsubscribeInterface {
  const doc = getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId});
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
