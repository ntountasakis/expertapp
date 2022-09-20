import {CallerCallState} from "../../call_state/caller/caller_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
// eslint-disable-next-line max-len
import {sendFcmCallJoinRequest} from "../../server/client_communication/fcm/send_fcm_call_join_request";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {PaymentStatus} from "../../firebase/firestore/models/payment_status";
import {StripePaymentIntentStates} from "../../stripe/constants";
// eslint-disable-next-line max-len
import {ServerCallBeginPaymentInitiateResolved} from "../../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";
// eslint-disable-next-line max-len
import {sendGrpcServerAgoraCredentials} from "../../server/client_communication/grpc/send_grpc_server_agora_credentials";

export function onCallerPaymentSuccessCallInitiate(clientMessageSender: ClientMessageSenderInterface,
    callState : BaseCallState,
    update: PaymentStatus): boolean {
  if (update.status == StripePaymentIntentStates.SUCCEEDED) {
    const paymentResolved: ServerCallBeginPaymentInitiateResolved = {};
    clientMessageSender.sendCallBeginPaymentInitiateResolved(paymentResolved);

    const callerCallState = callState as CallerCallState;
    sendFcmCallJoinRequest(callerCallState.callerBeginCallContext.calledFcmToken,
        callerCallState.callerBeginCallContext.callJoinRequest,
        callerCallState.callerBeginCallContext.transactionId);
    sendGrpcServerAgoraCredentials(clientMessageSender, callerCallState.callerBeginCallContext.agoraChannelName,
        callerCallState.callerBeginCallContext.callJoinRequest.callerUid);
    return true;
  }
  return false;
}