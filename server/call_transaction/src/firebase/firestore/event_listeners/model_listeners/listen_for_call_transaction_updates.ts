import {getCallTransactionDocumentRef} from "../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {BaseCallState} from "../../../../call_state/common/base_call_state";
import {FirestoreUnsubscribeInterface} from "../firestore_unsubscribe_interface";

export function listenForCallTransactionUpdates(callState: BaseCallState): FirestoreUnsubscribeInterface {
  const doc = getCallTransactionDocumentRef({transactionId: callState.transactionId});
  const unsubscribeFn = doc.onSnapshot((docSnapshot) => {
    const callTransaction = docSnapshot.data() as CallTransaction;
    callState.eventListenerManager.onEventUpdate({key: docSnapshot.id, type: "CallTransaction", update: callTransaction});
  }, async (err) => {
    await callState.log(`Encountered error: ${err}`);
  });

  return unsubscribeFn;
}
