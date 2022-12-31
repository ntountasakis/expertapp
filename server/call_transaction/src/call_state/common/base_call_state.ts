import * as grpc from "@grpc/grpc-js";
import {FirestoreListenerManager} from "../../firebase/firestore/event_listeners/firestore_listener_manager";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";

export class BaseCallState {
  userId: string;
  transactionId: string;
  isConnected: boolean;
  eventListenerManager: FirestoreListenerManager;
  onDisconnectFunction: CallOnDisconnectInterface;
  callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>;

  constructor({userId, transactionId, clientMessageSender, onDisconnect, callStream}:
    {onDisconnect: CallOnDisconnectInterface, clientMessageSender: ClientMessageSenderInterface,
        transactionId: string, userId: string, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>}) {
    this.transactionId = transactionId;
    this.eventListenerManager = new FirestoreListenerManager(clientMessageSender, this);
    this.onDisconnectFunction = onDisconnect;
    this.isConnected = true;
    this.userId = userId;
    this.callStream = callStream;
  }

  onDisconnect(): void {
    this.isConnected = false;
    this.eventListenerManager.onDisconnect();
    this.onDisconnectFunction({transactionId: this.transactionId,
      clientMessageSender: this.eventListenerManager.clientMessageSender,
      callState: this.eventListenerManager.callState});
  }
}
