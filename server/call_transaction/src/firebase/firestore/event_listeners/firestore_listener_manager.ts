import {FirestoreUnsubscribeInterface} from "./firestore_unsubscribe_interface";
import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {BaseCallState} from "../../../call_state/common/base_call_state";
import {FirestoreUpdateCallback} from "./firestore_update_callback";
import {Logger} from "../../../../../functions/src/shared/src/google_cloud/google_cloud_logger";

export class FirestoreListenerManager {
  clientMessageSender: ClientMessageSenderInterface;
  callState: BaseCallState;

  constructor(clientMessageSender: ClientMessageSenderInterface, callState: BaseCallState) {
    this.clientMessageSender = clientMessageSender;
    this.callState = callState;
  }

  listeners = new Map<string, [FirestoreUpdateCallback, FirestoreUnsubscribeInterface]>();

  unsubscribeToEvents(): void {
    this.listeners.forEach((value: [FirestoreUpdateCallback, FirestoreUnsubscribeInterface], key: string) => {
      const unsubscribeFn = value[1];
      unsubscribeFn();
    });
    this.listeners.clear();
  }

  listenForEventUpdates({key, updateCallback, unsubscribeFn}:
    { key: string, updateCallback: FirestoreUpdateCallback, unsubscribeFn: FirestoreUnsubscribeInterface }): void {
    this.listeners.set(key, [updateCallback, unsubscribeFn]);
  }

  async onEventUpdate({key, type, update}: { key: string, type: string, update: any }): Promise<void> {
    const listener: [FirestoreUpdateCallback, FirestoreUnsubscribeInterface] | undefined =
      this._getListener({key: key, type: type});
    if (listener === undefined) {
      return;
    }
    const updateCallback = listener[0];
    const isDone = await updateCallback(this.clientMessageSender, this.callState, update);
    this._onCallbackComplete({key: key, isDone: isDone, unsubscribeFn: listener[1]});
  }

  _getListener({key, type}: { key: string, type: string }):
    [FirestoreUpdateCallback, FirestoreUnsubscribeInterface] | undefined {
    const listener: [FirestoreUpdateCallback, FirestoreUnsubscribeInterface] | undefined =
      this.listeners.get(key);
    if (listener === undefined) {
      Logger.logError({
        logName: Logger.CALL_SERVER, message: `EventListenerManager. Cannot find listener with ID: ${key} Type: ${type}`,
      });
    }
    return listener;
  }

  _onCallbackComplete({key, isDone, unsubscribeFn}:
    { key: string, isDone: boolean, unsubscribeFn: FirestoreUnsubscribeInterface }): void {
    if (isDone) {
      this.listeners.delete(key);
      unsubscribeFn();
    }
  }
}
