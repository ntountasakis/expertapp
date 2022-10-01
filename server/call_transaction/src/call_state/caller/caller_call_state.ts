import {CallerBeginCallContext} from "./caller_begin_call_context";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {BaseCallState} from "../common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

export class CallerCallState extends BaseCallState {
  callerBeginCallContext: CallerBeginCallContext;
  hasInitiatedCallTerminatePayment: boolean;

  constructor({callerBeginCallContext, clientMessageSender, onDisconnect}:
    {callerBeginCallContext: CallerBeginCallContext, clientMessageSender: ClientMessageSenderInterface,
      onDisconnect: CallOnDisconnectInterface}) {
    super({transactionId: callerBeginCallContext.transactionId, clientMessageSender: clientMessageSender,
      onDisconnect: onDisconnect});
    this.callerBeginCallContext = callerBeginCallContext;
    this.hasInitiatedCallTerminatePayment = false;
  }
}
