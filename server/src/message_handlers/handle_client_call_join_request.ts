import {ClientCallJoinRequest} from "../protos/call_transaction_package/ClientCallJoinRequest";

export async function handleClientCallJoinRequest(callJoinRequest: ClientCallJoinRequest): Promise<void> {
  const transactionId = callJoinRequest.callTransactionId;
  const joinerId = callJoinRequest.joinerUid;
  console.log(`Got call join request from joinerId: ${joinerId} with transaction id: ${transactionId}`);
  return;
}
