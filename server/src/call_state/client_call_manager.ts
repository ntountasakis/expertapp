import {CallerBeginCallContext} from "./callback_contexts/caller_begin_call_context";
import {ClientCallOnDisconnectInterface} from "./client_call_on_disconnect_interface";
import {ClientCallState} from "./client_call_state";

export class ClientCallManager {
    clientCallStates = new Map<string, ClientCallState>();

    createCallStateOnCallerBegin({userId, callerBeginCallContext, callerDisconnectFunction}:
      {userId: string, callerBeginCallContext: CallerBeginCallContext,
      callerDisconnectFunction: ClientCallOnDisconnectInterface}): ClientCallState {
      const callState = new ClientCallState(callerBeginCallContext, callerDisconnectFunction);
      this.clientCallStates.set(userId, callState);
      console.log(`Created ClientCallState for UID: ${userId}`);
      return callState;
    }

    getCallState({userId}: {userId: string}): ClientCallState | undefined {
      return this.clientCallStates.get(userId);
    }

    onClientDisconnect({userId}: {userId: string}): void {
      const callState = this.clientCallStates.get(userId);
      if (callState === undefined) {
        console.error(`Unable to clear ClientCallState for UID: ${userId}. Does not exist`);
        return;
      }
      callState.onDisconnect();
      this.clientCallStates.delete(userId);
    }
}
