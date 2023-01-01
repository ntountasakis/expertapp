import * as grpc from "@grpc/grpc-js";
import {CallManager} from "../call_state/common/call_manager";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {InvalidClientMessageHandlerInterface} from "../message_sender/invalid_client_message_handler_interface";
import {isValidClientInitiateRequest} from "../message_validators/validate_client_call_initiate_request";
import {isValidClientJoinRequest} from "../message_validators/validate_client_call_join_request";
import {isValidClientMessageContainer} from "../message_validators/validate_client_message_container";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {ClientCallJoinRequest} from "../protos/call_transaction_package/ClientCallJoinRequest";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../protos/call_transaction_package/ServerMessageContainer";
import {handleClientCallInitiateRequest} from "./handle_client_call_initiate_request";
import {handleClientCallJoinRequest} from "./handle_client_call_join_request";

export async function dispatchClientMessage(
    {clientMessage, invalidMessageHandler, clientMessageSender, callManager, callStream}: {
    clientMessage: ClientMessageContainer,
    invalidMessageHandler: InvalidClientMessageHandlerInterface,
    clientMessageSender: ClientMessageSenderInterface,
    callManager: CallManager, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>}): Promise<boolean> {
  if (!checkMessageContainerValid(clientMessage, invalidMessageHandler)) return false;

  if (clientMessage.callInitiateRequest) {
    return await dispatchCallInitiateRequest(clientMessage.callInitiateRequest, invalidMessageHandler,
        clientMessageSender, callManager, callStream);
  } else if (clientMessage.callJoinRequest) {
    return await dispatchCallJoinRequest(clientMessage.callJoinRequest, invalidMessageHandler,
        clientMessageSender, callManager, callStream);
  }
  invalidMessageHandler("Unknown client message type");
  return false;
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

async function dispatchCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    invalidMessageHandler : InvalidClientMessageHandlerInterface,
    clientMessageSender: ClientMessageSenderInterface,
    clientCallManager: CallManager,
    callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>): Promise<boolean> {
  const [callInitiateRequestValid, callInitiateRequestInvalidErrorMessage] = isValidClientInitiateRequest(
      {callInitiateRequest: callInitiateRequest});
  if (!callInitiateRequestValid) {
    invalidMessageHandler(callInitiateRequestInvalidErrorMessage);
    return false;
  }
  return await handleClientCallInitiateRequest(callInitiateRequest, clientMessageSender, clientCallManager, callStream);
}

async function dispatchCallJoinRequest(callJoinRequest: ClientCallJoinRequest,
    invalidMessageHandler : InvalidClientMessageHandlerInterface,
    clientMessageSender: ClientMessageSenderInterface,
    callManager: CallManager, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>): Promise<boolean> {
  const [callJoinRequestValid, callJoinRequestInvalidErrorMessage] = isValidClientJoinRequest(
      {callJoinRequest: callJoinRequest});
  if (!callJoinRequestValid) {
    invalidMessageHandler(callJoinRequestInvalidErrorMessage);
    return false;
  }
  return await handleClientCallJoinRequest(callJoinRequest, clientMessageSender, callManager, callStream);
}
