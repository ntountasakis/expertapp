import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerCallJoinOrRequestResponse} from "../../../protos/call_transaction_package/ServerCallJoinOrRequestResponse";

export function sendGrpcCallJoinOrRequestSuccess(callTransactionId: string, secCallAuthFor: number, clientMessageSender: ClientMessageSenderInterface): void {
  const serverCallJoinOrRequestResponse: ServerCallJoinOrRequestResponse = {
    "success": true,
    "errorMessage": "",
    "callTransactionId": callTransactionId,
    "secondsCallAuthorizedFor": secCallAuthFor,
  };
  clientMessageSender.sendCallJoinOrRequestResponse(serverCallJoinOrRequestResponse);
}
