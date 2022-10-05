import {CallerCallState} from "../../call_state/caller/caller_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

import {sendFcmCallJoinRequest} from "../../../../shared/firebase/fcm/functions/send_fcm_call_join_request";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {StripePaymentIntentStates} from "../../../../shared/stripe/constants";

import {ServerCallBeginPaymentInitiateResolved} from "../../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";

import {sendGrpcServerAgoraCredentials} from "../../server/client_communication/grpc/send_grpc_server_agora_credentials";
import { PaymentStatus } from "../../../../shared/firebase/firestore/models/payment_status";

export function onCallerPaymentSuccessCallInitiate(clientMessageSender: ClientMessageSenderInterface,
    callState : BaseCallState,
    update: PaymentStatus): Promise<boolean> {
  if (update.status == StripePaymentIntentStates.SUCCEEDED) {
    const paymentResolved: ServerCallBeginPaymentInitiateResolved = {};
    clientMessageSender.sendCallBeginPaymentInitiateResolved(paymentResolved);

    const callerCallState = callState as CallerCallState;
    sendFcmCallJoinRequest(callerCallState.callerBeginCallContext.calledFcmToken,
        callerCallState.callerBeginCallContext.callJoinRequest,
        callerCallState.callerBeginCallContext.transactionId);
    sendGrpcServerAgoraCredentials(clientMessageSender, callerCallState.callerBeginCallContext.agoraChannelName,
        callerCallState.callerBeginCallContext.callJoinRequest.callerUid);
    return Promise.resolve(true);
  }
  return Promise.resolve(false);
}
