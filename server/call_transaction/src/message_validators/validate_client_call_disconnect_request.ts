import {ClientCallDisconnectRequest} from "../protos/call_transaction_package/ClientCallDisconnectRequest";

export function isValidClientDisconnectRequest({callDisconnectRequest}: {callDisconnectRequest: ClientCallDisconnectRequest}):
[valid: boolean, errorMessage: string] {
  if (callDisconnectRequest == null) {
    return [false, "DisconnectRequest request object null"];
  }
  if (callDisconnectRequest.uid == null || callDisconnectRequest.uid.length == 0) {
    return [false, "DisconnectRequest Error: UID empty or zero-length"];
  }
  return [true, ""];
}

