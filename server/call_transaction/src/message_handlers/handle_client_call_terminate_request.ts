
import {callerFinishCallTransaction} from "../call_events/caller/caller_finish_call_transaction";
import {CallerCallManager} from "../call_state/caller/caller_call_manager";
import {CallerCallState} from "../call_state/caller/caller_call_state";

import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallTerminateRequest} from "../protos/call_transaction_package/ClientCallTerminateRequest";


export async function handleClientCallTerminateRequest(callTerminateRequest: ClientCallTerminateRequest,
    clientMessageSender: ClientMessageSenderInterface, clientCallManager: CallerCallManager): Promise<void> {
  // todo: use return values
  console.log(`handline clientCallTerminateRequest for ID: ${callTerminateRequest.callTransactionId}`);

  const uid = callTerminateRequest.uid as string;
  const baseCallState = clientCallManager.getCallState({userId: uid});
  if (baseCallState === undefined) {
    throw new Error(`Cannot find existing CallState in handleClientCallTerminateRequest for ID:
    ${callTerminateRequest.callTransactionId}`);
  }
  if (callTerminateRequest.callTransactionId == undefined) {
    throw new Error("Caller cannot terminate call. TransactionId undefined");
  }
  await callerFinishCallTransaction({transactionId: callTerminateRequest.callTransactionId,
    clientMessageSender: clientMessageSender, callState: baseCallState as CallerCallState});
}
