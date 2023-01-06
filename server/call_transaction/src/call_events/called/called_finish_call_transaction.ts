import {CalledCallState} from "../../call_state/called/called_call_state";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {endCallTransactionCalled} from "../../firebase/firestore/functions/transaction/called/end_call_transaction_called";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ServerCallSummary} from "../../protos/call_transaction_package/ServerCallSummary";

export async function calledFinishCallTransaction({transactionId, clientMessageSender, callState}:
    {transactionId: string, clientMessageSender: ClientMessageSenderInterface,
        callState: BaseCallState}): Promise<void> {
  const calledCallState = callState as CalledCallState;
  if (!calledCallState.hasInitiatedCallFinish) {
    calledCallState.hasInitiatedCallFinish = true;
    const callSummary: ServerCallSummary = await endCallTransactionCalled({transactionId: transactionId});
    if (!callState.callStream.closed) {
      console.log("Sending call summary to called");
      clientMessageSender.sendCallSummary(callSummary);
    }
  }
}
