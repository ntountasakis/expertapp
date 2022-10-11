import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {BaseCallState} from "../common/base_call_state";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";

export class CalledCallState extends BaseCallState {
  hasInitiatedCallFinish: boolean;
  constructor({transactionId, clientMessageSender, onDisconnect}:
    {transactionId: string, clientMessageSender: ClientMessageSenderInterface,
      onDisconnect: CallOnDisconnectInterface}) {
    super({transactionId: transactionId, clientMessageSender: clientMessageSender, onDisconnect: onDisconnect});
    this.hasInitiatedCallFinish = false;
  }
}
