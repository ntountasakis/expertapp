import {CallerCallState} from "../../call_state/caller/caller_call_state";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {endCallTransactionCaller} from "../../firebase/firestore/functions/transaction/caller/end_call_transaction_caller";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ServerCallSummary} from "../../protos/call_transaction_package/ServerCallSummary";

export async function onCallerDisconnect({transactionId, clientMessageSender, callState}:
    {transactionId: string, clientMessageSender: ClientMessageSenderInterface,
        callState: BaseCallState}): Promise<void> {
  callState.log("Running onCallerDisconnect");
  const callerCallState = callState as CallerCallState;
  const callSummary: ServerCallSummary = await endCallTransactionCaller({transactionId: transactionId, callState: callerCallState});
  if (callState.isConnected()) {
    await clientMessageSender.sendCallSummary(callSummary);
  }
}
