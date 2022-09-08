import {endCallTransactionClientInitiated} from "../firebase/firestore/functions/end_call_transaction_client_initiated";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallTerminateRequest} from "../protos/call_transaction_package/ClientCallTerminateRequest";

export async function handleClientCallTerminateRequest(callTerminateRequest: ClientCallTerminateRequest,
    clientMessageSender: ClientMessageSenderInterface): Promise<void> {
  const transactionId = callTerminateRequest.callTransactionId;
  const uid = callTerminateRequest.uid;

  const [endTransactionValid, _] = await endCallTransactionClientInitiated({terminateRequest: callTerminateRequest});

  if (!endTransactionValid) {
    return;
  }
}
