import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerCallJoinOrRequestResponse} from "../../../protos/call_transaction_package/ServerCallJoinOrRequestResponse";

export async function sendGrpcCallJoinOrRequestFailure(
    errorMessage: string, clientMessageSender: ClientMessageSenderInterface): Promise<void> {
  console.error(errorMessage);
  const serverCallJoinOrRequestResponse: ServerCallJoinOrRequestResponse = {
    "success": false,
    "errorMessage": errorMessage,
  };
  clientMessageSender.sendCallJoinOrRequestResponse(serverCallJoinOrRequestResponse);
}
