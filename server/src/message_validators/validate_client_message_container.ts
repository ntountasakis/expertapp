import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";

export function isValidClientMessageContainer({clientMessage}: {clientMessage : ClientMessageContainer}):
[valid: boolean, errorMessage: string] {
  if (clientMessage != null) {
    return [true, ""];
  }
  return [false, "Client Message Container null"];
}
