import {FirestoreListenerManager} from "../../firebase/firestore/event_listeners/firestore_listener_manager";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";

export class BaseCallState {
  transactionId: string;
  isConnected: boolean;
  eventListenerManager: FirestoreListenerManager;
  onDisconnectFunction: CallOnDisconnectInterface;

  constructor({transactionId, clientMessageSender, onDisconnect}:
    {onDisconnect: CallOnDisconnectInterface, clientMessageSender: ClientMessageSenderInterface,
        transactionId: string}) {
    this.transactionId = transactionId;
    this.eventListenerManager = new FirestoreListenerManager(clientMessageSender, this);
    this.onDisconnectFunction = onDisconnect;
    this.isConnected = true;
  }

  onDisconnect(): void {
    this.isConnected = false;
    this.eventListenerManager.onDisconnect();
    this.onDisconnectFunction({transactionId: this.transactionId,
      clientMessageSender: this.eventListenerManager.clientMessageSender,
      callState: this.eventListenerManager.callState});
  }
}
