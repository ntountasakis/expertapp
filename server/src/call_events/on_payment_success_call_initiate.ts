import {sendServerAgoraCredentials} from "../agora/client_utils/send_server_agora_credentials";
import {ClientCallState} from "../call_state/client_call_state";
import {sendCallJoinRequest} from "../firebase/fcm/fcm_token_sender";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
// eslint-disable-next-line max-len
import {ServerCallBeginPaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";

export async function onPaymentSuccessCallInitiate(clientMessageSender: ClientMessageSenderInterface,
    clientCallState : ClientCallState): Promise<void> {
  const paymentResolved: ServerCallBeginPaymentInitiateResolved = {};
  clientMessageSender.sendCallBeginPaymentInitiateResolved(paymentResolved);

  sendCallJoinRequest(clientCallState.transaction.calledFcmToken, clientCallState.callJoinRequest,
      clientCallState.transaction.callTransactionId);
  sendServerAgoraCredentials(clientMessageSender, clientCallState.transaction.agoraChannelName,
      clientCallState.callJoinRequest.callerUid);
}
