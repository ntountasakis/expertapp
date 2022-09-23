
import {BaseCallState} from "../../call_state/common/base_call_state";
import {CallTransaction} from "../../firebase/firestore/models/call_transaction";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

export function onCalledTransactionUpdate(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, update: CallTransaction): Promise<boolean> {
  if (update.callHasEnded) {
    console.log("Called detected caller ended the call");
    clientMessageSender.sendCounterpartyLeftCall({});
    return Promise.resolve(true);
  } else if (update.calledHasJoined) {
    console.log("Called detected caller joined the call");
    clientMessageSender.sendCounterpartyJoinedCall({});
  }
  return Promise.resolve(false);
}
