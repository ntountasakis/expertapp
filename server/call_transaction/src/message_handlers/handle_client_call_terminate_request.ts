
import {callerSendPaymentRequestEndOfCall} from "../call_events/caller/caller_send_payment_request_end_of_call";
import {CallerCallManager} from "../call_state/caller/caller_call_manager";

import {endCallTransactionCallerInitiated} from "../firebase/firestore/functions/transaction/caller/end_call_transaction_caller_initiated";
import {EndCallTransactionReturnType} from "../firebase/firestore/functions/transaction/types/call_transaction_types";

import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallTerminateRequest} from "../protos/call_transaction_package/ClientCallTerminateRequest";


export async function handleClientCallTerminateRequest(callTerminateRequest: ClientCallTerminateRequest,
    clientMessageSender: ClientMessageSenderInterface, clientCallManager: CallerCallManager): Promise<void> {
  // todo: use return values
  console.log(`handline clientCallTerminateRequest for ID: ${callTerminateRequest.callTransactionId}`);
  const endCallPromise: EndCallTransactionReturnType =
    await endCallTransactionCallerInitiated({terminateRequest: callTerminateRequest});

  if (typeof endCallPromise === "string") {
    console.error("Leaving handleClientCallTerminateRequest on error");
    return;
  }
  const uid = callTerminateRequest.uid as string;
  const baseCallState = clientCallManager.getCallState({userId: uid});
  if (baseCallState === undefined) {
    console.error(`Cannot find existing CallState in handleClientCallTerminateRequest for ID:
    ${callTerminateRequest.callTransactionId}`);
    return;
  }

  callerSendPaymentRequestEndOfCall(clientMessageSender, baseCallState);
}
