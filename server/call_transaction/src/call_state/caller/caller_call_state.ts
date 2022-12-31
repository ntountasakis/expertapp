import * as grpc from "@grpc/grpc-js";
import {CallerBeginCallContext} from "./caller_begin_call_context";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {BaseCallState} from "../common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";

export class CallerCallState extends BaseCallState {
  callerBeginCallContext: CallerBeginCallContext;
  hasInitiatedCallFinish: boolean;

  constructor({callerBeginCallContext, clientMessageSender, onDisconnect, userId, callStream}:
    {callerBeginCallContext: CallerBeginCallContext, clientMessageSender: ClientMessageSenderInterface,
      onDisconnect: CallOnDisconnectInterface, userId: string, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>}) {
    super({transactionId: callerBeginCallContext.transactionId, clientMessageSender: clientMessageSender,
      onDisconnect: onDisconnect, userId: userId, callStream: callStream});
    this.callerBeginCallContext = callerBeginCallContext;
    this.hasInitiatedCallFinish = false;
  }
}
