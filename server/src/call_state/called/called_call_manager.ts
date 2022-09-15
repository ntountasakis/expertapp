import {BaseCallManager} from "../common/base_call_manager";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {CalledCallState} from "./called_call_state";

export class CalledCallManager extends BaseCallManager {
  createCallStateOnCallJoin({userId, transactionId, callerDisconnectFunction}:
      {userId: string, transactionId: string,
      callerDisconnectFunction: CallOnDisconnectInterface}): CalledCallState {
    const callState = new CalledCallState(
        {transactionId: transactionId, onDisconnect: callerDisconnectFunction});
    this.callStates.set(userId, callState);
    console.log(`Created CalledCallState for UID: ${userId}`);
    return callState;
  }
}
