import {BaseCallState} from "../call_state/common/base_call_state";
import {CallManager} from "../call_state/common/call_manager";

export async function handleClientCallDisconnectRequest(clientCallManager: CallManager, userId: string): Promise<boolean> {
  const callState: BaseCallState | undefined = clientCallManager.getCallState({userId: userId});
  if (callState !== undefined) {
    await callState.disconnect();
  } else {
    console.error(`Error: handleClientCallDisconnectRequest UserId: ${userId} not found`);
    return false;
  }
  return true;
}
