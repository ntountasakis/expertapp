import * as grpc from "@grpc/grpc-js";
import {FirestoreListenerManager} from "../../firebase/firestore/event_listeners/firestore_listener_manager";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";

export class BaseCallState {
  userId: string;
  transactionId: string;
  eventListenerManager: FirestoreListenerManager;
  onDisconnectFunction?: CallOnDisconnectInterface;
  callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>;
  _timer?: NodeJS.Timeout;

  constructor({userId, transactionId, clientMessageSender, onDisconnect, callStream}:
    {onDisconnect: CallOnDisconnectInterface, clientMessageSender: ClientMessageSenderInterface,
        transactionId: string, userId: string, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>}) {
    this.transactionId = transactionId;
    this.eventListenerManager = new FirestoreListenerManager(clientMessageSender, this);
    this.onDisconnectFunction = onDisconnect;
    this.userId = userId;
    this.callStream = callStream;
    this._timer = undefined;
  }

  async disconnect(): Promise<void> {
    await this.onDisconnect();
    this.callStream.end();
  }

  async onDisconnect(): Promise<void> {
    this.cancelTimers();
    this.eventListenerManager.unsubscribeToEvents();
    if (this.onDisconnectFunction !== undefined) {
      await this.onDisconnectFunction({transactionId: this.transactionId,
        clientMessageSender: this.eventListenerManager.clientMessageSender,
        callState: this.eventListenerManager.callState});
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

  log(message: string): void {
    console.log(`Message: ${message} UserId: ${this.userId} TransactionId: ${this.transactionId} `);
  }

  isConnected(): boolean {
    return !this.callStream.closed;
  }
}
