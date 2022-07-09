import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";

export function isValidClientInitiateRequest({callInitiateRequest}: {callInitiateRequest: ClientCallInitiateRequest}):
[valid: boolean, errorMessage: string] {
  if (callInitiateRequest == null) {
    return [false, "InitiateCall request object null"];
  }
  if (callInitiateRequest.calledUid == null || callInitiateRequest.calledUid.length == 0) {
    return [false, "InitiateCall Error: CalledUID empty or zero-length"];
  }
  if (callInitiateRequest.callerUid == null || callInitiateRequest.callerUid.length == 0) {
    return [false, "InitiateCall Error: CallerUID empty or zero-length"];
  }
  return [true, ""];
}

