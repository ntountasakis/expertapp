import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerCallRequestResponse} from "../../../protos/call_transaction_package/ServerCallRequestResponse";

export function sendGrpcCallRequestSuccess(callTransactionId: string,
    clientMessageSender: ClientMessageSenderInterface): void {
  const serverCallRequestResponse: ServerCallRequestResponse = {
    "success": true,
    "errorMessage": "",
    "callTransactionId": callTransactionId,
  };
  clientMessageSender.sendCallRequestResponse(serverCallRequestResponse);
}
