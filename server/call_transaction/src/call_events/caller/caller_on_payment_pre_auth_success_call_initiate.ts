import * as admin from "firebase-admin";
import {CallerCallState} from "../../call_state/caller/caller_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

import {sendFcmCallJoinRequest} from "../../../../shared/src/firebase/fcm/functions/send_fcm_call_join_request";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {sendGrpcServerAgoraCredentials} from "../../server/client_communication/grpc/send_grpc_server_agora_credentials";
import {PaymentStatus, PaymentStatusStates} from "../../../../shared/src/firebase/firestore/models/payment_status";
import {getCallTransactionDocumentRef} from "../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../shared/src/firebase/firestore/models/call_transaction";
import {ServerCallBeginPaymentPreAuthResolved} from "../../protos/call_transaction_package/ServerCallBeginPaymentPreAuthResolved";

export async function onCallerPaymentPreAuthSuccessCallInitiate(clientMessageSender: ClientMessageSenderInterface,
    callState : BaseCallState,
    update: PaymentStatus): Promise<boolean> {
  if (update.status == PaymentStatusStates.CHARGE_CONFIRMED) {
    const callerCallState = callState as CallerCallState;

    const callTransaction = await admin.firestore().runTransaction(async (transaction) => {
      const callTransactionRef = getCallTransactionDocumentRef({transactionId: callerCallState.callerBeginCallContext.transactionId});
      const callTransaction: CallTransaction = (await transaction.get(callTransactionRef)).data() as CallTransaction;
      transaction.update(callTransactionRef, {
        "calledWasRung": true,
      });
      return callTransaction;
    });

    const startRateString = callTransaction.expertRateCentsCallStart.toString();
    const perMinuteRateString = callTransaction.expertRateCentsPerMinute.toString();

    await callerCallState.setCallJoinExpirationTimer(30);

    const paymentPreAuthResolved: ServerCallBeginPaymentPreAuthResolved = {
      "joinCallTimeExpiryUtcMs": callerCallState.callJoinExpirationTimeUtcMs,
    };
    clientMessageSender.sendCallBeginPaymentPreAuthResolved(paymentPreAuthResolved, callerCallState);

    sendFcmCallJoinRequest({fcmToken: callerCallState.callerBeginCallContext.calledFcmToken,
      callerUid: callerCallState.callerBeginCallContext.callerUid,
      calledUid: callerCallState.callerBeginCallContext.calledUid,
      callTransactionId: callerCallState.callerBeginCallContext.transactionId,
      callRateStartCents: startRateString,
      callRatePerMinuteCents: perMinuteRateString,
      callJoinExpirationTimeUtcMs: callerCallState.callJoinExpirationTimeUtcMs});
    await sendGrpcServerAgoraCredentials(clientMessageSender, callerCallState.callerBeginCallContext.agoraChannelName,
        callerCallState.callerBeginCallContext.callerUid, callerCallState);
    return Promise.resolve(true);
  }
  return Promise.resolve(false);
}
