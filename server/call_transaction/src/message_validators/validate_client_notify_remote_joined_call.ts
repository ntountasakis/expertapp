import {ClientNotifyRemoteJoinedCall} from "../protos/call_transaction_package/ClientNotifyRemoteJoinedCall";

export function isValidClientNotifyRemotejoinedCall({clientNotifyRemoteJoinedCall}: {clientNotifyRemoteJoinedCall: ClientNotifyRemoteJoinedCall}):
[valid: boolean, errorMessage: string] {
  if (clientNotifyRemoteJoinedCall == null) {
    return [false, "ClientNotifyRemotedJoinedCall request object null"];
  }
  if (clientNotifyRemoteJoinedCall.clientUid == undefined || clientNotifyRemoteJoinedCall.clientUid.length == 0) {
    return [false, "ClientNotifyRemoteJoinedCall Error: clientUid empty or zero-length"];
  }
  if (clientNotifyRemoteJoinedCall.remoteUid == undefined || clientNotifyRemoteJoinedCall.remoteUid.length == 0) {
    return [false, "ClientNotifyRemoteJoinedCall Error: remoteUid empty or zero-length"];
  }
  return [true, ""];
}

