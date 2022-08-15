import * as admin from "firebase-admin";
import {CallManager} from "../call_state/call_manager";
import {PaymentStatus} from "../firebase/firestore/models/payment_status";

export function listenForPaymentStatusUpdates(paymentStatusId: string, callManager: CallManager): void {
  const doc = admin.firestore().collection("payment_statuses").doc(paymentStatusId);
  const unsubscribeFn = doc.onSnapshot((docSnapshot) => {
    const paymentStatus = docSnapshot.data() as PaymentStatus;
    console.log(`On payment status update. Uid: ${paymentStatus.uid} Status: ${paymentStatus.status} 
        CentsToBeCollected: ${paymentStatus.centsCollected} CentsCollected: ${paymentStatus.centsCollected}`);
  }, (err) => {
    console.log(`Encountered error: ${err}`);
  });
  callManager.registerPaymentStatusUnsubscribeFn(paymentStatusId, unsubscribeFn);
}
