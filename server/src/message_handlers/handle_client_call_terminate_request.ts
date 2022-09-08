import {endCallTransactionClientInitiated} from "../firebase/firestore/functions/end_call_transaction_client_initiated";
import {ClientCallTerminateRequest} from "../protos/call_transaction_package/ClientCallTerminateRequest";

export async function handleClientCallTerminateRequest(callTerminateRequest: ClientCallTerminateRequest):
Promise<void> {
  // todo: use return values
  await endCallTransactionClientInitiated({terminateRequest: callTerminateRequest});
}
