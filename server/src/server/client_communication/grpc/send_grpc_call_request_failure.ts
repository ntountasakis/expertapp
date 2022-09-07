import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerCallRequestResponse} from "../../../protos/call_transaction_package/ServerCallRequestResponse";

export function sendGrpcCallRequestFailure(
    errorMessage: string, clientMessageSender: ClientMessageSenderInterface): void {
  console.error(errorMessage);
  const serverCallRequestResponse: ServerCallRequestResponse = {
    "success": false,
    "errorMessage": errorMessage,
  };
  clientMessageSender.sendCallRequestResponse(serverCallRequestResponse);
}
