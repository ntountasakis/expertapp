import {CallerBeginCallContext} from "./callback_contexts/caller_begin_call_context";
import {ClientCallState} from "./client_call_state";

export class ClientCallManager {
    clientCallStates = new Map<string, ClientCallState>();

    createCallStateOnCallerBegin({userId, callerBeginCallContext}:
      {userId: string, callerBeginCallContext: CallerBeginCallContext}): ClientCallState {
      const callState = new ClientCallState(callerBeginCallContext);
      this.clientCallStates.set(userId, callState);
      console.log(`Created ClientCallState for UID: ${userId}`);
      return callState;
    }

    getCallState({userId}: {userId: string}): ClientCallState | undefined {
      return this.clientCallStates.get(userId);
    }

    clearCallState({userId}: {userId: string}): void {
      if (!this.clientCallStates.delete(userId)) {
        console.error(`Unable to clear ClientCallState for UID: ${userId}. Does not exist`);
      }
    }
}
