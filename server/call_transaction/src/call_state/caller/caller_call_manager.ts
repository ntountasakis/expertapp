import {CallerBeginCallContext} from "./caller_begin_call_context";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {CallerCallState} from "./caller_call_state";
import {BaseCallManager} from "../common/base_call_manager";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

export class CallerCallManager extends BaseCallManager {
  createCallStateOnCallerBegin({userId, callerBeginCallContext, callerDisconnectFunction,
    clientMessageSender}: {userId: string, callerBeginCallContext: CallerBeginCallContext,
      callerDisconnectFunction: CallOnDisconnectInterface,
    clientMessageSender: ClientMessageSenderInterface}): CallerCallState {
    const callState = new CallerCallState(
        {callerBeginCallContext: callerBeginCallContext, onDisconnect: callerDisconnectFunction,
          clientMessageSender: clientMessageSender});
    this.callStates.set(userId, callState);
    console.log(`Created CallerCallState for UID: ${userId}`);
    return callState;
  }
}
