import {CallerBeginCallContext} from "./callback_contexts/caller_begin_call_context";
import {ClientCallState} from "./client_call_state";

export class ClientCallManager {
    clientCallStates = new Map<string, ClientCallState>();

    createCallStateOnCallerBegin(callerBeginCallContext: CallerBeginCallContext): ClientCallState {
      const callState = new ClientCallState(callerBeginCallContext);
      this.clientCallStates.set(callerBeginCallContext.transactionId, callState);
      return callState;
    }

    getCallState(transactionId: string): ClientCallState | undefined {
      return this.clientCallStates.get(transactionId);
    }
}
