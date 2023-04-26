import * as grpc from "@grpc/grpc-js";
import {Logger} from "../../../../shared/src/google_cloud/google_cloud_logger";
import {FirestoreListenerManager} from "../../firebase/firestore/event_listeners/firestore_listener_manager";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";

export class BaseCallState {
  userId: string;
  transactionId: string;
  version: string;
  eventListenerManager: FirestoreListenerManager;
  onDisconnectFunction?: CallOnDisconnectInterface;
  callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>;
  isCaller: boolean;
  sentCallReady: boolean;
  _timer?: NodeJS.Timeout;

  constructor({userId, transactionId, version, clientMessageSender, onDisconnect, callStream, isCaller}:
    {
      onDisconnect: CallOnDisconnectInterface, clientMessageSender: ClientMessageSenderInterface,
      transactionId: string, userId: string, version: string, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>,
      isCaller: boolean,
    }) {
    this.transactionId = transactionId;
    this.version = version;
    this.eventListenerManager = new FirestoreListenerManager(clientMessageSender, this);
    this.onDisconnectFunction = onDisconnect;
    this.userId = userId;
    this.callStream = callStream;
    this._timer = undefined;
    this.isCaller = isCaller;
    this.sentCallReady = false;
  }

  async disconnect(): Promise<void> {
    await this.onDisconnect(false);
    this.callStream.end();
  }

  async onDisconnect(clientRequested: boolean): Promise<void> {
    this.cancelTimers();
    this.eventListenerManager.unsubscribeToEvents();
    if (this.onDisconnectFunction !== undefined) {
      await this.onDisconnectFunction({
        transactionId: this.transactionId,
        clientMessageSender: this.eventListenerManager.clientMessageSender,
        callState: this.eventListenerManager.callState, clientRequested: clientRequested,
      });
      this.onDisconnectFunction = undefined;
    }
  }

  setTimer(numSeconds: number): void {
    this._timer = setTimeout(this.disconnect.bind(this), numSeconds * 1000);
  }

  cancelTimers(): void {
    if (this._timer !== undefined) {
      clearTimeout(this._timer);
      this._timer = undefined;
    }
  }

  async log(message: string): Promise<void> {
    const userKey = this.isCaller ? "userId" : "expertId";
    await Logger.log({
      logName: Logger.CALL_SERVER, message: message,
      labels: new Map([["callTransactionId", this.transactionId], [userKey, this.userId], ["version", this.version]]),
    });
  }

  isConnected(): boolean {
    return !this.callStream.closed;
  }
}
