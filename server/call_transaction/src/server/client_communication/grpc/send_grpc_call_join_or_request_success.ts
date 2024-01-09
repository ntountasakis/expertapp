import {BaseCallState} from "../../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerCallJoinOrRequestResponse} from "../../../protos/call_transaction_package/ServerCallJoinOrRequestResponse";

export function sendGrpcCallJoinOrRequestSuccess(callTransactionId: string, secCallAuthFor: number, clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState): void {
  const serverCallJoinOrRequestResponse: ServerCallJoinOrRequestResponse = {
    "success": true,
    "errorMessage": "",
    "callTransactionId": callTransactionId,
    "secondsCallAuthorizedFor": secCallAuthFor,
  };
  clientMessageSender.sendCallJoinOrRequestResponse(serverCallJoinOrRequestResponse, callState);
}
