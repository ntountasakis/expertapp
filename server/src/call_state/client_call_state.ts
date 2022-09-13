import {CallerBeginCallContext} from "./callback_contexts/caller_begin_call_context";

export class ClientCallState {
  callerBeginCallContext: CallerBeginCallContext;

  constructor(callerBeginCallContext: CallerBeginCallContext) {
    this.callerBeginCallContext = callerBeginCallContext;
  }
}
