import {CallTransaction} from "../../../../functions/src/shared/src/firebase/firestore/models/call_transaction";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

export async function onCalledTransactionUpdate(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, update: CallTransaction): Promise<boolean> {
  if (update.callerFinishedTransaction) {
    await callState.log("Counterparty ended the call");
    await callState.disconnect();
    return true;
  } else if (update.calledHasJoined) {
    await callState.log("Counterparty joined the call");
    clientMessageSender.sendCounterpartyJoinedCall({}, callState);
    if (update.callBeginTimeUtcMs != 0 && !callState.sentCallReady) {
      clientMessageSender.sendServerBothPartiesReadyForCall({callStartUtcMs: update.callBeginTimeUtcMs}, callState);
      callState.sentCallReady = true;
    }
  }
  return false;
}
