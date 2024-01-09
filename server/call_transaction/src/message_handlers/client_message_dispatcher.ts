import * as grpc from "@grpc/grpc-js";
import {CallManager} from "../call_state/common/call_manager";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {InvalidClientMessageHandlerInterface} from "../message_sender/invalid_client_message_handler_interface";
import {isValidClientDisconnectRequest} from "../message_validators/validate_client_call_disconnect_request";
import {isValidClientInitiateRequest} from "../message_validators/validate_client_call_initiate_request";
import {isValidClientJoinRequest} from "../message_validators/validate_client_call_join_request";
import {isValidClientMessageContainer} from "../message_validators/validate_client_message_container";
import {ClientCallDisconnectRequest} from "../protos/call_transaction_package/ClientCallDisconnectRequest";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {ClientCallJoinRequest} from "../protos/call_transaction_package/ClientCallJoinRequest";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../protos/call_transaction_package/ServerMessageContainer";
import {handleClientCallDisconnectRequest} from "./handle_client_call_disconnect_request";
import {handleClientCallInitiateRequest} from "./handle_client_call_initiate_request";
import {handleClientCallJoinRequest} from "./handle_client_call_join_request";
import {ClientNotifyRemoteJoinedCall} from "../protos/call_transaction_package/ClientNotifyRemoteJoinedCall";
import {isValidClientNotifyRemotejoinedCall} from "../message_validators/validate_client_notify_remote_joined_call";
import {handleClientNotifyRemoteJoinedCall} from "./handle_client_notify_remote_joined_call";

export async function dispatchClientMessage(
    {clientMessage, invalidMessageHandler, clientMessageSender, callManager, callStream}: {
    clientMessage: ClientMessageContainer,
    invalidMessageHandler: InvalidClientMessageHandlerInterface,
    clientMessageSender: ClientMessageSenderInterface,
    callManager: CallManager, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>
  }): Promise<void> {
  if (!checkMessageContainerValid(clientMessage, invalidMessageHandler)) {
    throw new Error("Server received a malformed client message.");
  }
  if (clientMessage.keepAlivePing) {
    await clientMessageSender.sendServerKeepAlivePong();
  } else if (clientMessage.callInitiateRequest) {
    await dispatchCallInitiateRequest(clientMessage.callInitiateRequest, invalidMessageHandler,
        clientMessageSender, callManager, callStream);
  } else if (clientMessage.callJoinRequest) {
    await dispatchCallJoinRequest(clientMessage.callJoinRequest, invalidMessageHandler,
        clientMessageSender, callManager, callStream);
  } else if (clientMessage.callDisconnectRequest) {
    await dispatchCallDisconnectRequest(clientMessage.callDisconnectRequest, invalidMessageHandler, callManager);
  } else if (clientMessage.notifyRemoteJoinedCall) {
    await dispatchNotifyRemoteJoinedCall(clientMessage.notifyRemoteJoinedCall, invalidMessageHandler, callManager);
  } else {
    invalidMessageHandler("Unknown client message type");
  }
}

function checkMessageContainerValid(clientMessage: ClientMessageContainer,
    invalidMessageHandler: InvalidClientMessageHandlerInterface): boolean {
  const [messageContainerValid, messageContainerInvalidErrorMessage] = isValidClientMessageContainer(
      {clientMessage: clientMessage});
  if (!messageContainerValid) {
    invalidMessageHandler(messageContainerInvalidErrorMessage);
  }
  return messageContainerValid;
}

async function dispatchCallDisconnectRequest(callDisconnectRequest: ClientCallDisconnectRequest,
    invalidMessageHandler: InvalidClientMessageHandlerInterface, callManager: CallManager): Promise<void> {
  const [callDisconnectRequestValid, callDisconnectRequestInvalidErrorMessage] = isValidClientDisconnectRequest(
      {callDisconnectRequest: callDisconnectRequest});
  if (!callDisconnectRequestValid) {
    invalidMessageHandler(callDisconnectRequestInvalidErrorMessage);
    return;
  }
  handleClientCallDisconnectRequest(callManager, callDisconnectRequest.uid!);
}

async function dispatchNotifyRemoteJoinedCall(remoteJoinedCall: ClientNotifyRemoteJoinedCall,
    invalidMessageHandler: InvalidClientMessageHandlerInterface, callManager: CallManager): Promise<void> {
  const [callNotifyValid, callNotifyInvalidErrorMessage] = isValidClientNotifyRemotejoinedCall({clientNotifyRemoteJoinedCall: remoteJoinedCall});
  if (!callNotifyValid) {
    invalidMessageHandler(callNotifyInvalidErrorMessage);
    return;
  }
  handleClientNotifyRemoteJoinedCall(callManager, remoteJoinedCall);
}

async function dispatchCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    invalidMessageHandler: InvalidClientMessageHandlerInterface,
    clientMessageSender: ClientMessageSenderInterface,
    clientCallManager: CallManager,
    callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>): Promise<void> {
  const [callInitiateRequestValid, callInitiateRequestInvalidErrorMessage] = isValidClientInitiateRequest(
      {callInitiateRequest: callInitiateRequest});
  if (!callInitiateRequestValid) {
    invalidMessageHandler(callInitiateRequestInvalidErrorMessage);
    return;
  }
  await handleClientCallInitiateRequest(callInitiateRequest, clientMessageSender, clientCallManager, callStream);
}

async function dispatchCallJoinRequest(callJoinRequest: ClientCallJoinRequest,
    invalidMessageHandler: InvalidClientMessageHandlerInterface,
    clientMessageSender: ClientMessageSenderInterface,
    callManager: CallManager, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>): Promise<void> {
  const [callJoinRequestValid, callJoinRequestInvalidErrorMessage] = isValidClientJoinRequest(
      {callJoinRequest: callJoinRequest});
  if (!callJoinRequestValid) {
    invalidMessageHandler(callJoinRequestInvalidErrorMessage);
    return;
  }
  await handleClientCallJoinRequest(callJoinRequest, clientMessageSender, callManager, callStream);
}
