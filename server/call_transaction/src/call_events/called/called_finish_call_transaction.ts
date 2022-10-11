import {CallTransaction} from "../../../../shared/firebase/firestore/models/call_transaction";
import {CalledCallState} from "../../call_state/called/called_call_state";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {endCallTransactionCalled} from "../../firebase/firestore/functions/transaction/called/end_call_transaction_called";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {calledSendPaymentTransferEndOfCall} from "./called_send_payment_transfer_end_of_call";

export async function calledFinishCallTransaction({transactionId, clientMessageSender, callState}:
    {transactionId: string, clientMessageSender: ClientMessageSenderInterface,
        callState: BaseCallState}): Promise<void> {
  const callerCallState = callState as CalledCallState;
  if (!callerCallState.hasInitiatedCallFinish) {
    callerCallState.hasInitiatedCallFinish = true; // todo: atomic?
    const callTransaction: CallTransaction = await endCallTransactionCalled({transactionId: transactionId});
    await calledSendPaymentTransferEndOfCall({callTransaction: callTransaction});
  }
}
