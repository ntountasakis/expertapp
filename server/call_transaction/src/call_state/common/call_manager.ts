import * as grpc from "@grpc/grpc-js";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";
import {CalledCallState} from "../called/called_call_state";
import {CallerBeginCallContext} from "../caller/caller_begin_call_context";
import {CallerCallState} from "../caller/caller_call_state";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {BaseCallState} from "./base_call_state";
import {Logger} from "../../../../shared/src/google_cloud/google_cloud_logger";

export class CallManager {
  _callStates = new Map<string, BaseCallState>();

  async creatCallState({userId, state}: { userId: string, state: BaseCallState }) {
    await state.log(`Created call state for userId: ${userId}`);
    this._callStates.set(userId, state);
  }

  async onClientDisconnect({userId}: { userId: string }): Promise<void> {
    const callState = this.getCallState({userId: userId});
    if (callState === undefined) {
      Logger.logError({
        logName: Logger.CALL_SERVER, message: `Unable to clear CallState for UID: ${userId}. Does not exist`,
        labels: new Map([["userId", userId]]),
      });
      return;
    }
    callState.onDisconnect(true);
    await this._removeCallState({userId: userId, callState: callState});
  }

  async createCallStateOnCallerBegin({userId, callerBeginCallContext, callerDisconnectFunction,
    clientMessageSender, callStream, version}: {
      userId: string, version: string, callerBeginCallContext: CallerBeginCallContext,
      callerDisconnectFunction: CallOnDisconnectInterface,
      clientMessageSender: ClientMessageSenderInterface, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>
    }): Promise<CallerCallState> {
    const callState = new CallerCallState(
        {
          callerBeginCallContext: callerBeginCallContext, onDisconnect: callerDisconnectFunction,
          clientMessageSender: clientMessageSender, userId: userId, callStream: callStream, version: version,
        });
    await this.creatCallState({userId: userId, state: callState});
    await callState.log(`Created CallerCallState for UID: ${userId}`);
    return callState;
  }

  createCallStateOnCallJoin({userId, transactionId, disconnectionFunction: disconnectFunction, clientMessageSender, callStream, version}:
    {
      userId: string, transactionId: string, version: string,
      disconnectionFunction: CallOnDisconnectInterface,
      clientMessageSender: ClientMessageSenderInterface, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>
    }): CalledCallState {
    const callState = new CalledCallState(
        {
          transactionId: transactionId, onDisconnect: disconnectFunction,
          clientMessageSender: clientMessageSender, userId: userId, callStream: callStream, version: version,
        });
    this.creatCallState({userId: userId, state: callState});
    return callState;
  }

  getCallState({userId}: { userId: string }): BaseCallState | undefined {
    return this._callStates.get(userId);
  }

  async _removeCallState({userId, callState}: { userId: string, callState: BaseCallState }) {
    await callState.log(`Removed call state for userId: ${userId}`);
    this._callStates.delete(userId);
  }
}
