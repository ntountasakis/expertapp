
import { CallTransaction } from "../../../../shared/firebase/firestore/models/call_transaction";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {endCallTransactionCalled} from "../../firebase/firestore/functions/transaction/called/end_call_transaction_called";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

export function onCalledTransactionUpdate(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, update: CallTransaction): Promise<boolean> {
  if (update.callHasEnded) {
    console.log("Called detected caller ended the call");
    clientMessageSender.sendCounterpartyLeftCall({});
    endCallTransactionCalled({transactionId: update.callTransactionId});
    return Promise.resolve(true);
  } else if (update.calledHasJoined) {
    console.log("Called detected caller joined the call");
    clientMessageSender.sendCounterpartyJoinedCall({});
  }
  return Promise.resolve(false);
}
