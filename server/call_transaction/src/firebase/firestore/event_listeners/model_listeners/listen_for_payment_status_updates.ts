import {getPaymentStatusDocumentRef} from "../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {PaymentStatus} from "../../../../../../shared/src/firebase/firestore/models/payment_status";
import {BaseCallState} from "../../../../call_state/common/base_call_state";
import {FirestoreUnsubscribeInterface} from "../firestore_unsubscribe_interface";

export function listenForPaymentStatusUpdates(paymentStatusId: string, callState: BaseCallState): FirestoreUnsubscribeInterface {
  const doc = getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId});
  const unsubscribeFn = doc.onSnapshot(async (docSnapshot) => {
    const paymentStatus = docSnapshot.data() as PaymentStatus;
    await callState.log(`On payment status update. PaymentStatusId: ${paymentStatusId} 
      Uid: ${paymentStatus.uid} Status: ${paymentStatus.status} CentsRequestedAuthorized: ${paymentStatus.centsRequestedAuthorized}
      CentsAuthorized: ${paymentStatus.centsAuthorized} CentsRequestedCapture: ${paymentStatus.centsRequestedCapture} 
      CentsCaptured: ${paymentStatus.centsCaptured} CentsPaid: ${paymentStatus.centsPaid}`);
    callState.eventListenerManager.onEventUpdate({key: docSnapshot.id, type: "PaymentStatus", update: paymentStatus});
  }, async (err) => {
    await callState.log(`Encountered error: ${err}`);
  });

  return unsubscribeFn;
}
