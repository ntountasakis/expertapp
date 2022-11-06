import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {CalledCallState} from "../called/called_call_state";
import {CallerBeginCallContext} from "../caller/caller_begin_call_context";
import {CallerCallState} from "../caller/caller_call_state";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {BaseCallState} from "./base_call_state";

export class CallManager {
  _callStates = new Map<string, BaseCallState>();

  creatCallState({userId, state}: {userId: string, state: BaseCallState}) {
    console.log(`Created call state for userId: ${userId}`);
    this._callStates.set(userId, state);
  }

  getCallState({userId}: {userId: string}): BaseCallState | undefined {
    return this._callStates.get(userId);
  }

  removeCallState({userId}: {userId: string}) {
    console.log(`Removed call state for userId: ${userId}`);
    this._callStates.delete(userId);
  }

  onClientDisconnect({userId}: {userId: string}): void {
    console.log(`Removing call state. UserId: ${userId} disconnected`);
    const callState = this.getCallState({userId: userId});
    if (callState === undefined) {
      console.error(`Unable to clear CallState for UID: ${userId}. Does not exist`);
      return;
    }
    callState.onDisconnect();
    this.removeCallState({userId: userId});
  }

  createCallStateOnCallerBegin({userId, callerBeginCallContext, callerDisconnectFunction,
    clientMessageSender}: {userId: string, callerBeginCallContext: CallerBeginCallContext,
      callerDisconnectFunction: CallOnDisconnectInterface,
    clientMessageSender: ClientMessageSenderInterface}): CallerCallState {
    const callState = new CallerCallState(
        {callerBeginCallContext: callerBeginCallContext, onDisconnect: callerDisconnectFunction,
          clientMessageSender: clientMessageSender});
    this.creatCallState({userId: userId, state: callState});
    console.log(`Created CallerCallState for UID: ${userId}`);
    return callState;
  }

  createCallStateOnCallJoin({userId, transactionId, callerDisconnectFunction, clientMessageSender}:
      {userId: string, transactionId: string,
      callerDisconnectFunction: CallOnDisconnectInterface,
    clientMessageSender: ClientMessageSenderInterface}): CalledCallState {
    const callState = new CalledCallState(
        {transactionId: transactionId, onDisconnect: callerDisconnectFunction,
          clientMessageSender: clientMessageSender});
    this.creatCallState({userId: userId, state: callState});
    console.log(`Created CalledCallState for UID: ${userId}`);
    return callState;
  }
}