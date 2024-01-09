import {CallerCallState} from "../call_state/caller/caller_call_state";
import {BaseCallState} from "../call_state/common/base_call_state";
import {CallManager} from "../call_state/common/call_manager";
import {markClientNotifyRemoteJoinedCall} from "../firebase/firestore/functions/transaction/common/mark_client_notify_remote_joined_call";
import {ClientNotifyRemoteJoinedCall} from "../protos/call_transaction_package/ClientNotifyRemoteJoinedCall";

export async function handleClientNotifyRemoteJoinedCall(
    clientCallManager: CallManager, clientCallNotifyRemoteJoinedCall: ClientNotifyRemoteJoinedCall): Promise<void> {
  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
  const callState: BaseCallState | undefined = clientCallManager.getCallState({userId: clientCallNotifyRemoteJoinedCall.clientUid!});
  if (callState === undefined) {
    throw new Error(`Error: handleClientCallDisconnectRequest UserId: ${clientCallNotifyRemoteJoinedCall.clientUid} not found`);
  }
  callState.log(`Handling ClientNotifyRemoteJoinedCall ${JSON.stringify(clientCallNotifyRemoteJoinedCall)}`);
  await markClientNotifyRemoteJoinedCall({notify: clientCallNotifyRemoteJoinedCall, transactionId: callState.transactionId,
    isCaller: callState instanceof CallerCallState});
}
