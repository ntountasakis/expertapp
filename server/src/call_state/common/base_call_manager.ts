import {BaseCallState} from "./base_call_state";

export class BaseCallManager {
    callStates = new Map<string, BaseCallState>();

    getCallState({userId}: {userId: string}): BaseCallState | undefined {
      return this.callStates.get(userId);
    }

    onClientDisconnect({userId}: {userId: string}): void {
      const callState = this.callStates.get(userId);
      if (callState === undefined) {
        console.error(`Unable to clear CallState for UID: ${userId}. Does not exist`);
        return;
      }
      callState.onDisconnect();
      this.callStates.delete(userId);
    }
}
