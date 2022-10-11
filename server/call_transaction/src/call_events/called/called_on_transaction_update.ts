
import {CallTransaction} from "../../../../shared/src/firebase/firestore/models/call_transaction";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {calledFinishCallTransaction} from "./called_finish_call_transaction";

export async function onCalledTransactionUpdate(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, update: CallTransaction): Promise<boolean> {
  if (update.callHasEnded) {
    console.log("Called detected caller ended the call");
    clientMessageSender.sendCounterpartyLeftCall({});
    await calledFinishCallTransaction({transactionId: update.callTransactionId,
      clientMessageSender: clientMessageSender, callState: callState});
    return Promise.resolve(true);
  } else if (update.calledHasJoined) {
    console.log("Called detected caller joined the call");
    clientMessageSender.sendCounterpartyJoinedCall({});
  }
  return Promise.resolve(false);
}
