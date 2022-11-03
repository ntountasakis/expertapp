
import {calledFinishCallTransaction} from "../call_events/called/called_finish_call_transaction";
import {callerFinishCallTransaction} from "../call_events/caller/caller_finish_call_transaction";
import {CalledCallState} from "../call_state/called/called_call_state";
import {CallerCallState} from "../call_state/caller/caller_call_state";
import {CallManager} from "../call_state/common/call_manager";

import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallTerminateRequest} from "../protos/call_transaction_package/ClientCallTerminateRequest";


export async function handleClientCallTerminateRequest(callTerminateRequest: ClientCallTerminateRequest,
    clientMessageSender: ClientMessageSenderInterface, callManager: CallManager): Promise<void> {
  // todo: use return values
  const uid = callTerminateRequest.uid as string;
  console.log(`handline clientCallTerminateRequest for transactionID: ${callTerminateRequest.callTransactionId} 
    uid: ${uid}`);

  const baseCallState = callManager.getCallState({userId: uid});
  if (baseCallState === undefined) {
    throw new Error(`Cannot find existing CallState in handleClientCallTerminateRequest for User ID: ${uid}`);
  }
  if (callTerminateRequest.callTransactionId == undefined) {
    throw new Error("Caller cannot terminate call. TransactionId undefined");
  }
  if (baseCallState instanceof CallerCallState) {
    await callerFinishCallTransaction({transactionId: callTerminateRequest.callTransactionId,
      clientMessageSender: clientMessageSender, callState: baseCallState});
  } else if (baseCallState instanceof CalledCallState) {
    await calledFinishCallTransaction({transactionId: callTerminateRequest.callTransactionId,
      clientMessageSender: clientMessageSender, callState: baseCallState});
  } else {
    throw new Error("BaseCallState neither CallerCallState nor CalledCallState");
  }
}
