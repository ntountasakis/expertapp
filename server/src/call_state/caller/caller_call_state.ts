import {CallerBeginCallContext} from "./caller_begin_call_context";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {BaseCallState} from "../common/base_call_state";

export class CallerCallState extends BaseCallState {
  callerBeginCallContext: CallerBeginCallContext;

  constructor({callerBeginCallContext, onDisconnect}:
    {callerBeginCallContext: CallerBeginCallContext, onDisconnect: CallOnDisconnectInterface}) {
    super({transactionId: callerBeginCallContext.transactionId, onDisconnect: onDisconnect});
    this.callerBeginCallContext = callerBeginCallContext;
  }
}
