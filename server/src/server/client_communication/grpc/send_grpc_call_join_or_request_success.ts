import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerCallJoinOrRequestResponse} from "../../../protos/call_transaction_package/ServerCallJoinOrRequestResponse";

export function sendGrpcCallJoinOrRequestSuccess(callTransactionId: string,
    clientMessageSender: ClientMessageSenderInterface): void {
  const serverCallJoinOrRequestResponse: ServerCallJoinOrRequestResponse = {
    "success": true,
    "errorMessage": "",
    "callTransactionId": callTransactionId,
  };
  clientMessageSender.sendCallJoinOrRequestResponse(serverCallJoinOrRequestResponse);
}
