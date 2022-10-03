import { getCallTransactionDocumentRef } from "../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import { CallTransaction } from "../../../../../../shared/firebase/firestore/models/call_transaction";
import {FirestoreListenerManager} from "../firestore_listener_manager";
import {FirestoreUnsubscribeInterface} from "../firestore_unsubscribe_interface";

export function listenForCallTransactionUpdates(
    transactionId: string, listenerManager: FirestoreListenerManager): FirestoreUnsubscribeInterface {
  const doc = getCallTransactionDocumentRef({transactionId: transactionId});
  const unsubscribeFn = doc.onSnapshot((docSnapshot) => {
    const callTransaction = docSnapshot.data() as CallTransaction;
    console.log(`CallTransaction: ${transactionId} updated`);
    listenerManager.onEventUpdate({key: docSnapshot.id, type: "CallTransaction", update: callTransaction});
  }, (err) => {
    console.log(`Encountered error: ${err}`);
  });

  return unsubscribeFn;
}
