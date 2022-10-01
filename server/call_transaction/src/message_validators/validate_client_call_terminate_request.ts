import {ClientCallTerminateRequest} from "../protos/call_transaction_package/ClientCallTerminateRequest";

export function isValidClientTerminateRequest({callTerminateRequest}:
    {callTerminateRequest: ClientCallTerminateRequest}):
[valid: boolean, errorMessage: string] {
  if (callTerminateRequest == null) {
    return [false, "CallTerminateRequest Error: request object null"];
  }
  if (callTerminateRequest.callTransactionId == null || callTerminateRequest.callTransactionId.length == 0) {
    return [false, "CallTerminateRequest Error: call transaction id empty or zero-length"];
  }
  return [true, ""];
}

