import {BaseCallState} from "../../call_state/common/base_call_state";
import {endCallTransactionCalled} from "../../firebase/firestore/functions/transaction/called/end_call_transaction_called";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

export async function onCalledDisconnect({transactionId, clientMessageSender, callState}:
    {transactionId: string, clientMessageSender: ClientMessageSenderInterface,
        callState: BaseCallState, clientRequested: boolean}): Promise<void> {
  await callState.log("Running onCalledDisconnect");
  const callSummary = await endCallTransactionCalled({transactionId: transactionId, callState: callState});
  if (callState.isConnected()) {
    await clientMessageSender.sendCallSummary(callSummary, callState);
  }
}
