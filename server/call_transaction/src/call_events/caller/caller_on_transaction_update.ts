import {CallTransaction} from "../../../../shared/src/firebase/firestore/models/call_transaction";
import {CallerCallState} from "../../call_state/caller/caller_call_state";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

export async function onCallerTransactionUpdate(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, update: CallTransaction): Promise<boolean> {
  if (update.calledFinishedTransaction) {
    await callState.log("Caller detected called ended the call");
    await callState.disconnect();
    return true;
  } else if (update.calledHasJoined) {
    await callState.log("Caller detected called joined the call");
    (callState as CallerCallState).cancelTimers();
    clientMessageSender.sendCounterpartyJoinedCall({secondsCallAuthorizedFor: update.maxCallTimeSec}, callState);
    if (update.callBeginTimeUtcMs != 0 && !callState.sentCallReady) {
      await clientMessageSender.sendServerBothPartiesReadyForCall({callStartUtcMs: update.callBeginTimeUtcMs}, callState);
      callState.sentCallReady = true;
    }
  }
  return false;
}
