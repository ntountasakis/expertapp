import {EventListenerManager} from "../../event_listeners/event_listener_manager";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";

export class BaseCallState {
  transactionId: string;
  eventListenerManager: EventListenerManager;
  onDisconnectFunction: CallOnDisconnectInterface;

  constructor({transactionId, onDisconnect}: {onDisconnect: CallOnDisconnectInterface, transactionId: string}) {
    this.transactionId = transactionId;
    this.eventListenerManager = new EventListenerManager();
    this.onDisconnectFunction = onDisconnect;
  }

  onDisconnect(): void {
    this.eventListenerManager.onDisconnect();
    this.onDisconnectFunction({transactionId: this.transactionId});
  }
}
