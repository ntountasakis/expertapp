import {CallTransaction} from "../../../../shared/src/firebase/firestore/models/call_transaction";
import {CallerCallState} from "../../call_state/caller/caller_call_state";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {callerFinishCallTransaction} from "./caller_finish_call_transaction";

export async function onCallerTransactionUpdate(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, update: CallTransaction): Promise<boolean> {
  if (update.callHasEnded) {
    console.log("Caller detected called ended the call");
    await callerFinishCallTransaction({transactionId: update.callTransactionId,
      clientMessageSender: clientMessageSender, callState: callState});
    callState.callStream.end();
    return true;
  } else if (update.calledHasJoined) {
    console.log("Caller detected called joined the call");
    (callState as CallerCallState).cancelCallJoinExpirationTimer();
    clientMessageSender.sendCounterpartyJoinedCall({secondsCallAuthorizedFor: update.maxCallTimeSec});
  }
  return false;
}
