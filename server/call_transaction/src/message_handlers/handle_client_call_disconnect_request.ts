import {BaseCallState} from "../call_state/common/base_call_state";
import {CallManager} from "../call_state/common/call_manager";

export async function handleClientCallDisconnectRequest(clientCallManager: CallManager, userId: string): Promise<void> {
  const callState: BaseCallState | undefined = clientCallManager.getCallState({userId: userId});
  if (callState !== undefined) {
    await callState.log("Received ClientCallDisconnectRequest");
    await callState.disconnect();
  } else {
    throw new Error(`Error: handleClientCallDisconnectRequest UserId: ${userId} not found`);
  }
}
