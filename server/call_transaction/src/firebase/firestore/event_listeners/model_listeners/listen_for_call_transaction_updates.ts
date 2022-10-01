import {FirestoreListenerManager} from "../firestore_listener_manager";
import {FirestoreUnsubscribeInterface} from "../firestore_unsubscribe_interface";
import {CallTransaction} from "../../models/call_transaction";
import {getCallTransactionRef} from "../../functions/util/model_fetchers";

export function listenForCallTransactionUpdates(
    transactionId: string, listenerManager: FirestoreListenerManager): FirestoreUnsubscribeInterface {
  const doc = getCallTransactionRef(transactionId);
  const unsubscribeFn = doc.onSnapshot((docSnapshot) => {
    const callTransaction = docSnapshot.data() as CallTransaction;
    console.log(`CallTransaction: ${transactionId} updated`);
    listenerManager.onEventUpdate({key: docSnapshot.id, type: "CallTransaction", update: callTransaction});
  }, (err) => {
    console.log(`Encountered error: ${err}`);
  });

  return unsubscribeFn;
}
