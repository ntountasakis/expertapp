import {EventListenerManager} from "../../event_listeners/event_listener_manager";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";

export class BaseCallState {
  transactionId: string;
  eventListenerManager: EventListenerManager;
  onDisconnectFunction: CallOnDisconnectInterface;

  constructor({transactionId, clientMessageSender, onDisconnect}:
    {onDisconnect: CallOnDisconnectInterface, clientMessageSender: ClientMessageSenderInterface,
        transactionId: string}) {
    this.transactionId = transactionId;
    this.eventListenerManager = new EventListenerManager(clientMessageSender, this);
    this.onDisconnectFunction = onDisconnect;
  }

  onDisconnect(): void {
    this.eventListenerManager.onDisconnect();
    this.onDisconnectFunction({transactionId: this.transactionId});
  }
}
