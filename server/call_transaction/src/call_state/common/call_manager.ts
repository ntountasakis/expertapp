import * as grpc from "@grpc/grpc-js";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";
import {CalledCallState} from "../called/called_call_state";
import {CallerBeginCallContext} from "../caller/caller_begin_call_context";
import {CallerCallState} from "../caller/caller_call_state";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {BaseCallState} from "./base_call_state";

export class CallManager {
  _callStates = new Map<string, BaseCallState>();

  creatCallState({userId, state}: {userId: string, state: BaseCallState}) {
    state.log(`Created call state for userId: ${userId}`);
    this._callStates.set(userId, state);
  }

  onClientDisconnect({userId}: {userId: string}): void {
    const callState = this._getCallState({userId: userId});
    if (callState === undefined) {
      console.error(`Unable to clear CallState for UID: ${userId}. Does not exist`);
      return;
    } else if (callState instanceof CalledCallState) {
      (callState as CalledCallState).cancelMaxCallLengthTimer();
    }
    callState.onDisconnect();
    this._removeCallState({userId: userId, callState: callState});
  }

  createCallStateOnCallerBegin({userId, callerBeginCallContext, callerDisconnectFunction,
    clientMessageSender, callStream}: {userId: string, callerBeginCallContext: CallerBeginCallContext,
      callerDisconnectFunction: CallOnDisconnectInterface,
    clientMessageSender: ClientMessageSenderInterface, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>}): CallerCallState {
    const callState = new CallerCallState(
        {callerBeginCallContext: callerBeginCallContext, onDisconnect: callerDisconnectFunction,
          clientMessageSender: clientMessageSender, userId: userId, callStream: callStream});
    this.creatCallState({userId: userId, state: callState});
    callState.log(`Created CallerCallState for UID: ${userId}`);
    return callState;
  }

  createCallStateOnCallJoin({userId, transactionId, callerDisconnectFunction, clientMessageSender, callStream}:
      {userId: string, transactionId: string,
      callerDisconnectFunction: CallOnDisconnectInterface,
    clientMessageSender: ClientMessageSenderInterface, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>}): CalledCallState {
    const callState = new CalledCallState(
        {transactionId: transactionId, onDisconnect: callerDisconnectFunction,
          clientMessageSender: clientMessageSender, userId: userId, callStream: callStream});
    this.creatCallState({userId: userId, state: callState});
    callState.log(`Created CalledCallState for UID: ${userId}`);
    return callState;
  }

  _getCallState({userId}: {userId: string}): BaseCallState | undefined {
    return this._callStates.get(userId);
  }

  _removeCallState({userId, callState}: {userId: string, callState: BaseCallState}) {
    callState.log(`Removed call state for userId: ${userId}`);
    this._callStates.delete(userId);
  }
}
