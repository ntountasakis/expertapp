import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {InvalidClientMessageHandlerInterface} from "../message_sender/invalid_client_message_handler_interface";
import {isValidClientInitiateRequest} from "../message_validators/validate_client_call_initiate_request";
import {isValidClientJoinRequest} from "../message_validators/validate_client_call_join_request";
import {isValidClientMessageContainer} from "../message_validators/validate_client_message_container";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {handleClientCallInitiateRequest} from "./handle_client_call_initiate_request";
import {handleClientCallJoinRequest} from "./handle_client_call_join_request";

export function dispatchClientMessage({clientMessage, invalidMessageHandler, clientMessageSender}:
    {clientMessage: ClientMessageContainer, invalidMessageHandler: InvalidClientMessageHandlerInterface,
        clientMessageSender: ClientMessageSenderInterface}): void {
  {
    const [messageContainerValid, messageContainerInvalidErrorMessage] = isValidClientMessageContainer(
        {clientMessage: clientMessage});
    if (!messageContainerValid) {
      invalidMessageHandler(messageContainerInvalidErrorMessage);
      return;
    }
  }
  if (clientMessage.callInitiateRequest) {
    const callInitiateRequest = clientMessage.callInitiateRequest;
    const [callInitiateRequestValid, callInitiateRequestInvalidErrorMessage] = isValidClientInitiateRequest(
        {callInitiateRequest: callInitiateRequest});
    if (!callInitiateRequestValid) {
      invalidMessageHandler(callInitiateRequestInvalidErrorMessage);
      return;
    }
    handleClientCallInitiateRequest(callInitiateRequest, clientMessageSender);
    return;
  }
  if (clientMessage.callJoinRequest) {
    const callJoinRequest = clientMessage.callJoinRequest;
    const [callJoinRequestValid, callJoinRequestInvalidErrorMessage] = isValidClientJoinRequest(
        {callJoinRequest: callJoinRequest});
    if (!callJoinRequestValid) {
      invalidMessageHandler(callJoinRequestInvalidErrorMessage);
      return;
    }
    handleClientCallJoinRequest(callJoinRequest, clientMessageSender);
    return;
  }

  invalidMessageHandler("Unknown client message type");
}
