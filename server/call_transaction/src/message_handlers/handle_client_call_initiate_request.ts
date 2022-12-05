import {createCallTransaction} from "../firebase/firestore/functions/transaction/caller/create_call_transaction";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {onCallerPaymentSuccessCallInitiate} from "../call_events/caller/caller_on_payment_success_call_initiate";
import {CallManager} from "../call_state/common/call_manager";

import {sendGrpcServerCallBeginPaymentInitiate} from "../server/client_communication/grpc/send_grpc_server_call_begin_payment_initiate";
import {sendGrpcCallJoinOrRequestSuccess} from "../server/client_communication/grpc/send_grpc_call_join_or_request_success";

import {onCallerTransactionUpdate} from "../call_events/caller/caller_on_transaction_update";

import {listenForPaymentStatusUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_payment_status_updates";

import {listenForCallTransactionUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_call_transaction_updates";
import {CallTransaction} from "../../../shared/src/firebase/firestore/models/call_transaction";
import {CallerCallState} from "../call_state/caller/caller_call_state";
import {callerFinishCallTransaction} from "../call_events/caller/caller_finish_call_transaction";
import {CallerBeginCallContext} from "../call_state/caller/caller_begin_call_context";
import {ExpertRate} from "../../../shared/src/firebase/firestore/models/expert_rate";


export async function handleClientCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    clientMessageSender: ClientMessageSenderInterface, clientCallManager: CallManager): Promise<boolean> {
  console.log(`InitiateCall request begin. Caller Uid: ${callInitiateRequest.callerUid} 
      Called Uid: ${callInitiateRequest.calledUid}`);

  // todo: call join request poor name as the caller isnt the joiner, also used for fcm not for this context

  const calledUid = callInitiateRequest.calledUid as string;
  const callerUid = callInitiateRequest.callerUid as string;

  const [didCreateCall, stripeCustomerId, paymentIntentClientSecret, ephemeralKey, optCallTransaction, optExpertRate] =
    await createCallTransaction({callerUid: callerUid, calledUid: calledUid});
  if (!didCreateCall) {
    return false;
  }
  const callTransaction = optCallTransaction as CallTransaction;
  const expertRate = optExpertRate as ExpertRate;

  const newClientCallState: CallerCallState = _createNewCallState({callManager: clientCallManager, callTransaction: callTransaction,
    calledUid: calledUid, callerUid: callerUid, expertRate: expertRate, clientMessageSender: clientMessageSender});

  _listenForPaymentSuccess({callState: newClientCallState, callTransaction: callTransaction});
  _listenForCallTransactionUpdates({callState: newClientCallState, callTransaction: callTransaction});

  sendGrpcCallJoinOrRequestSuccess(callTransaction.callTransactionId, clientMessageSender);
  sendGrpcServerCallBeginPaymentInitiate(clientMessageSender, paymentIntentClientSecret, ephemeralKey, stripeCustomerId);

  return true;
}

function _createNewCallState({callTransaction, callerUid, calledUid, expertRate, clientMessageSender, callManager}:
  {callManager: CallManager, callTransaction: CallTransaction, callerUid: string, calledUid: string,
    expertRate: ExpertRate, clientMessageSender: ClientMessageSenderInterface}): CallerCallState {
  const callBeginCallerContext = new CallerBeginCallContext({transactionId: callTransaction.callTransactionId,
    agoraChannelName: callTransaction.agoraChannelName, calledFcmToken: callTransaction.calledFcmToken,
    callerUid: callerUid, calledUid: calledUid, expertRate: expertRate});
  return callManager.createCallStateOnCallerBegin({
    userId: callTransaction.callerUid, callerBeginCallContext: callBeginCallerContext,
    callerDisconnectFunction: callerFinishCallTransaction,
    clientMessageSender: clientMessageSender});
}

function _listenForPaymentSuccess({callState, callTransaction}:
  {callState: CallerCallState, callTransaction: CallTransaction}) {
  callState.eventListenerManager.listenForEventUpdates({key: callTransaction.callerCallStartPaymentStatusId,
    updateCallback: onCallerPaymentSuccessCallInitiate,
    unsubscribeFn: listenForPaymentStatusUpdates(
        callTransaction.callerCallStartPaymentStatusId, callState.eventListenerManager)});
}

function _listenForCallTransactionUpdates({callState, callTransaction}:
  {callState: CallerCallState, callTransaction: CallTransaction}) {
  callState.eventListenerManager.listenForEventUpdates({key: callTransaction.callTransactionId,
    updateCallback: onCallerTransactionUpdate,
    unsubscribeFn: listenForCallTransactionUpdates(
        callTransaction.callTransactionId, callState.eventListenerManager)});
}
