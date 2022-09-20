import {BaseCallState} from "../../call_state/common/base_call_state";
import {CallTransaction} from "../../firebase/firestore/models/call_transaction";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

export function onCallerTransactionUpdate(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, update: CallTransaction): boolean {
  if (update.callHasEnded) {
    console.log("Caller detected called ended the call");
    clientMessageSender.sendCounterpartyLeftCall({});
    return true;
  } else if (update.calledHasJoined) {
    console.log("Caller detected called joined the call");
    clientMessageSender.sendCounterpartyJoinedCall({});
  }
  return false;
}
