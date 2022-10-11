import {CallTransaction} from "../../../../shared/src/firebase/firestore/models/call_transaction";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {callerFinishCallTransaction} from "./caller_finish_call_transaction";

export async function onCallerTransactionUpdate(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, update: CallTransaction): Promise<boolean> {
  if (update.callHasEnded) {
    console.log("Caller detected called ended the call");
    clientMessageSender.sendCounterpartyLeftCall({});
    await callerFinishCallTransaction({transactionId: update.callTransactionId,
      clientMessageSender: clientMessageSender, callState: callState});
    return true;
  } else if (update.calledHasJoined) {
    console.log("Caller detected called joined the call");
    clientMessageSender.sendCounterpartyJoinedCall({});
  }
  return false;
}
