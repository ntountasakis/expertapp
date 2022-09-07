import {sendGrpcServerAgoraCredentials} from "../server/client_communication/grpc/send_grpc_server_agora_credentials";
import {ClientCallState} from "../call_state/client_call_state";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
// eslint-disable-next-line max-len
import {ServerCallBeginPaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";
import {sendFcmCallJoinRequest} from "../server/client_communication/fcm/send_call_join_request";

export async function onPaymentSuccessCallInitiate(clientMessageSender: ClientMessageSenderInterface,
    clientCallState : ClientCallState): Promise<void> {
  const paymentResolved: ServerCallBeginPaymentInitiateResolved = {};
  clientMessageSender.sendCallBeginPaymentInitiateResolved(paymentResolved);

  sendFcmCallJoinRequest(clientCallState.transaction.calledFcmToken, clientCallState.callJoinRequest,
      clientCallState.transaction.callTransactionId);
  sendGrpcServerAgoraCredentials(clientMessageSender, clientCallState.transaction.agoraChannelName,
      clientCallState.callJoinRequest.callerUid);
}