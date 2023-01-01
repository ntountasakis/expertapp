
import {CallTransaction} from "../../../../shared/src/firebase/firestore/models/call_transaction";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {calledFinishCallTransaction} from "./called_finish_call_transaction";

export async function onCalledTransactionUpdate(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, update: CallTransaction): Promise<boolean> {
  if (update.callHasEnded) {
    console.log("Counterparty ended the call");
    await calledFinishCallTransaction({transactionId: update.callTransactionId,
      clientMessageSender: clientMessageSender, callState: callState});
    callState.callStream.end();
    return Promise.resolve(true);
  } else if (update.calledHasJoined) {
    console.log("Counterparty joined the call");
    clientMessageSender.sendCounterpartyJoinedCall({secondsCallAuthorizedFor: update.maxCallTimeSec});
  }
  return Promise.resolve(false);
}
