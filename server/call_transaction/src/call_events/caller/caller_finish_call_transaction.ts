import {CallerCallState} from "../../call_state/caller/caller_call_state";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {endCallTransactionCaller} from "../../firebase/firestore/functions/transaction/caller/end_call_transaction_caller";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {callerSendPaymentRequestEndOfCall} from "./caller_send_payment_request_end_of_call";

export async function callerFinishCallTransaction({transactionId, clientMessageSender, callState}:
    {transactionId: string, clientMessageSender: ClientMessageSenderInterface,
        callState: BaseCallState}): Promise<void> {
  const callerCallState = callState as CallerCallState;
  if (!callerCallState.hasInitiatedCallFinish) {
    callerCallState.hasInitiatedCallFinish = true; // todo: atomic?
    const callTransaction = await endCallTransactionCaller({transactionId: transactionId});
    await callerSendPaymentRequestEndOfCall(clientMessageSender, callState, callTransaction);
  }
}
