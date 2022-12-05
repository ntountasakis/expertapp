import {CallerCallState} from "../../call_state/caller/caller_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

import {sendFcmCallJoinRequest} from "../../../../shared/src/firebase/fcm/functions/send_fcm_call_join_request";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {StripePaymentIntentStates} from "../../../../shared/src/stripe/constants";

import {ServerCallBeginPaymentInitiateResolved} from "../../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";

import {sendGrpcServerAgoraCredentials} from "../../server/client_communication/grpc/send_grpc_server_agora_credentials";
import {PaymentStatus} from "../../../../shared/src/firebase/firestore/models/payment_status";
import {getCallTransactionDocumentRef} from "../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../shared/src/firebase/firestore/models/call_transaction";

export async function onCallerPaymentSuccessCallInitiate(clientMessageSender: ClientMessageSenderInterface,
    callState : BaseCallState,
    update: PaymentStatus): Promise<boolean> {
  if (update.status == StripePaymentIntentStates.SUCCEEDED) {
    const paymentResolved: ServerCallBeginPaymentInitiateResolved = {};
    clientMessageSender.sendCallBeginPaymentInitiateResolved(paymentResolved);

    const callerCallState = callState as CallerCallState;
    const callTransaction = (await getCallTransactionDocumentRef({
      transactionId: callerCallState.callerBeginCallContext.transactionId}).get()).data() as CallTransaction;

    const startRateString = callTransaction.expertRateCentsCallStart.toString();
    const perMinuteRateString = callTransaction.expertRateCentsPerMinute.toString();

    sendFcmCallJoinRequest({fcmToken: callerCallState.callerBeginCallContext.calledFcmToken,
      joinRequest: callerCallState.callerBeginCallContext.callJoinRequest,
      callTransactionId: callerCallState.callerBeginCallContext.transactionId,
      callRateStartCents: startRateString,
      callRatePerMinuteCents: perMinuteRateString});
    sendGrpcServerAgoraCredentials(clientMessageSender, callerCallState.callerBeginCallContext.agoraChannelName,
        callerCallState.callerBeginCallContext.callJoinRequest.callerUid);
    return Promise.resolve(true);
  }
  return Promise.resolve(false);
}
