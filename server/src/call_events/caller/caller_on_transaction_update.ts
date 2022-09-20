import {BaseCallState} from "../../call_state/common/base_call_state";
import {CallTransaction} from "../../firebase/firestore/models/call_transaction";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

export function onCallerTransactionUpdate(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, update: CallTransaction): boolean {
  if (update.callHasEnded) {
    console.log("Caller detected callled ended the call");
    return true;
  }
  return false;
}
