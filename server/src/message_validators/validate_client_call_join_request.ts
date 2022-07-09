import {ClientCallJoinRequest} from "../protos/call_transaction_package/ClientCallJoinRequest";

export function isValidClientJoinRequest({callJoinRequest}: {callJoinRequest: ClientCallJoinRequest}):
[valid: boolean, errorMessage: string] {
  if (callJoinRequest == null) {
    return [false, "CallJoinRequest Error: request object null"];
  }
  if (callJoinRequest.callTransactionId == null || callJoinRequest.callTransactionId.length == 0) {
    return [false, "CallJoinRequest Error: call transaction id empty or zero-length"];
  }
  if (callJoinRequest.joinerUid == null || callJoinRequest.joinerUid.length == 0) {
    return [false, "CallJoinRequest Error: call joiner id empty or zero-length"];
  }
  return [true, ""];
}

