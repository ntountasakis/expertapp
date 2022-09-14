import {EventListenerManager} from "../event_listeners/event_listener_manager";
import {CallerBeginCallContext} from "./callback_contexts/caller_begin_call_context";
import {ClientCallOnDisconnectInterface} from "./client_call_on_disconnect_interface";

export class ClientCallState {
  callerBeginCallContext: CallerBeginCallContext;
  eventListenerManager: EventListenerManager;
  onDisconnectFunction: ClientCallOnDisconnectInterface;

  constructor(callerBeginCallContext: CallerBeginCallContext, onDisconnect: ClientCallOnDisconnectInterface) {
    this.callerBeginCallContext = callerBeginCallContext;
    this.eventListenerManager = new EventListenerManager();
    this.onDisconnectFunction = onDisconnect;
  }

  onDisconnect(): void {
    this.eventListenerManager.onDisconnect();
    this.onDisconnectFunction({transactionId: this.callerBeginCallContext.transactionId});
  }
}
