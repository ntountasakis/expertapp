import {sendGrpcServerAgoraCredentials} from "../server/client_communication/grpc/send_grpc_server_agora_credentials";
import {ClientCallState} from "../call_state/client_call_state";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
// eslint-disable-next-line max-len
import {ServerCallBeginPaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";
import {sendFcmCallJoinRequest} from "../server/client_communication/fcm/send_fcm_call_join_request";

export async function onPaymentSuccessCallInitiate(clientMessageSender: ClientMessageSenderInterface,
    clientCallState : ClientCallState): Promise<void> {
  const paymentResolved: ServerCallBeginPaymentInitiateResolved = {};
  clientMessageSender.sendCallBeginPaymentInitiateResolved(paymentResolved);

  sendFcmCallJoinRequest(clientCallState.callerBeginCallContext.calledFcmToken,
      clientCallState.callerBeginCallContext.callJoinRequest,
      clientCallState.callerBeginCallContext.transactionId);
  sendGrpcServerAgoraCredentials(clientMessageSender, clientCallState.callerBeginCallContext.agoraChannelName,
      clientCallState.callerBeginCallContext.callJoinRequest.callerUid);
}
