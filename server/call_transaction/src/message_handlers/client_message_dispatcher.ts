import {CallManager} from "../call_state/common/call_manager";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {InvalidClientMessageHandlerInterface} from "../message_sender/invalid_client_message_handler_interface";
import {isValidClientInitiateRequest} from "../message_validators/validate_client_call_initiate_request";
import {isValidClientJoinRequest} from "../message_validators/validate_client_call_join_request";
import {isValidClientTerminateRequest} from "../message_validators/validate_client_call_terminate_request";
import {isValidClientMessageContainer} from "../message_validators/validate_client_message_container";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {ClientCallJoinRequest} from "../protos/call_transaction_package/ClientCallJoinRequest";
import {ClientCallTerminateRequest} from "../protos/call_transaction_package/ClientCallTerminateRequest";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {handleClientCallInitiateRequest} from "./handle_client_call_initiate_request";
import {handleClientCallJoinRequest} from "./handle_client_call_join_request";
import {handleClientCallTerminateRequest} from "./handle_client_call_terminate_request";

export async function dispatchClientMessage(
    {clientMessage, invalidMessageHandler, clientMessageSender, callManager}: {
    clientMessage: ClientMessageContainer,
    invalidMessageHandler: InvalidClientMessageHandlerInterface,
    clientMessageSender: ClientMessageSenderInterface,
    callManager: CallManager}): Promise<void> {
  if (!checkMessageContainerValid(clientMessage, invalidMessageHandler)) return;

  if (clientMessage.callInitiateRequest) {
    await dispatchCallInitiateRequest(clientMessage.callInitiateRequest, invalidMessageHandler,
        clientMessageSender, callManager);
  } else if (clientMessage.callJoinRequest) {
    await dispatchCallJoinRequest(clientMessage.callJoinRequest, invalidMessageHandler,
        clientMessageSender, callManager);
  } else if (clientMessage.callTerminateRequest) {
    await dispatchCallTerminateRequest(clientMessage.callTerminateRequest, invalidMessageHandler,
        clientMessageSender, callManager);
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

async function dispatchCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    invalidMessageHandler : InvalidClientMessageHandlerInterface,
    clientMessageSender: ClientMessageSenderInterface,
    clientCallManager: CallManager): Promise<void> {
  const [callInitiateRequestValid, callInitiateRequestInvalidErrorMessage] = isValidClientInitiateRequest(
      {callInitiateRequest: callInitiateRequest});
  if (!callInitiateRequestValid) {
    invalidMessageHandler(callInitiateRequestInvalidErrorMessage);
    return;
  }
  await handleClientCallInitiateRequest(callInitiateRequest, clientMessageSender, clientCallManager);
}

async function dispatchCallJoinRequest(callJoinRequest: ClientCallJoinRequest,
    invalidMessageHandler : InvalidClientMessageHandlerInterface,
    clientMessageSender: ClientMessageSenderInterface,
    CallManager: CallManager): Promise<void> {
  const [callJoinRequestValid, callJoinRequestInvalidErrorMessage] = isValidClientJoinRequest(
      {callJoinRequest: callJoinRequest});
  if (!callJoinRequestValid) {
    invalidMessageHandler(callJoinRequestInvalidErrorMessage);
    return;
  }
  await handleClientCallJoinRequest(callJoinRequest, clientMessageSender, CallManager);
}

async function dispatchCallTerminateRequest(callTerminateRequest: ClientCallTerminateRequest,
    invalidMessageHandler : InvalidClientMessageHandlerInterface,
    clientMessageSender: ClientMessageSenderInterface,
    clientCallManager: CallManager): Promise<void> {
  const [callTerminateRequestValid, callTerminateRequestInvalidErrorMessage] = isValidClientTerminateRequest(
      {callTerminateRequest: callTerminateRequest});
  if (!callTerminateRequestValid) {
    invalidMessageHandler(callTerminateRequestInvalidErrorMessage);
  } else {
    handleClientCallTerminateRequest(callTerminateRequest, clientMessageSender, clientCallManager);
  }
}
