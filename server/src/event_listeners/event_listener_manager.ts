import {EventUnsubscribeInterface} from "./event_unsubscribe_interface";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {BaseCallState} from "../call_state/common/base_call_state";
import {EventUpdateCallback} from "./event_callbacks";

export class EventListenerManager {
    clientMessageSender: ClientMessageSenderInterface;
    callState: BaseCallState;

    constructor(clientMessageSender: ClientMessageSenderInterface, callState: BaseCallState) {
      this.clientMessageSender = clientMessageSender;
      this.callState = callState;
    }

    listeners = new Map<string, [EventUpdateCallback, EventUnsubscribeInterface]>();

    onDisconnect(): void {
      this.listeners.forEach((value: [EventUpdateCallback, EventUnsubscribeInterface], key: string) => {
        const unsubscribeFn = value[1];
        console.log(`Unsubscribing from Listener: ${key}`);
        unsubscribeFn();
      });
    }

    listenForEventUpdates({key, updateCallback, unsubscribeFn} :
      {key: string, updateCallback: EventUpdateCallback, unsubscribeFn: EventUnsubscribeInterface}): void {
      this.listeners.set(key, [updateCallback, unsubscribeFn]);
    }

    onEventUpdate({key, type, update} : {key: string, type: string, update: any}): void {
      const listener : [EventUpdateCallback, EventUnsubscribeInterface] | undefined =
        this._getListener({key: key, type: type});
      if (listener === undefined) {
        return;
      }
      const updateCallback = listener[0];
      const isDone = updateCallback(this.clientMessageSender, this.callState, update);
      this._onCallbackComplete({key: key, isDone: isDone, unsubscribeFn: listener[1]});
    }

    _getListener({key, type}: {key: string, type: string}):
      [EventUpdateCallback, EventUnsubscribeInterface] | undefined {
      const listener : [EventUpdateCallback, EventUnsubscribeInterface] | undefined =
        this.listeners.get(key);
      if (listener === undefined) {
        console.error(`EventListenerManager. Cannot find listener with ID: ${key} Type: ${type}`);
      }
      return listener;
    }

    _onCallbackComplete({key, isDone, unsubscribeFn}:
      {key: string, isDone: boolean, unsubscribeFn: EventUnsubscribeInterface}): void {
      if (isDone) {
        this.listeners.delete(key);
        unsubscribeFn();
      }
    }
}
