import {createCallTransaction} from "../firebase/firestore/functions/transaction/caller/create_call_transaction";
import {CallJoinRequest} from "../../../shared/src/firebase/fcm/messages/call_join_request";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {onCallerPaymentSuccessCallInitiate} from "../call_events/caller/caller_on_payment_success_call_initiate";
import {CallManager} from "../call_state/common/call_manager";

import {sendGrpcServerCallBeginPaymentInitiate} from "../server/client_communication/grpc/send_grpc_server_call_begin_payment_initiate";
import {sendGrpcCallJoinOrRequestSuccess} from "../server/client_communication/grpc/send_grpc_call_join_or_request_success";
import {CallerBeginCallContext} from "../call_state/caller/caller_begin_call_context";

import {onCallerTransactionUpdate} from "../call_events/caller/caller_on_transaction_update";

import {listenForPaymentStatusUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_payment_status_updates";

import {listenForCallTransactionUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_call_transaction_updates";
import {CallTransaction} from "../../../shared/src/firebase/firestore/models/call_transaction";
import createStripePaymentIntent from "../../../shared/src/stripe/payment_intent_creator";
import {PrivateUserInfo} from "../../../shared/src/firebase/firestore/models/private_user_info";
import {getPrivateUserDocumentNoTransact} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallerCallState} from "../call_state/caller/caller_call_state";
import {callerFinishCallTransaction} from "../call_events/caller/caller_finish_call_transaction";


export async function handleClientCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    clientMessageSender: ClientMessageSenderInterface, clientCallManager: CallManager): Promise<void> {
  console.log(`InitiateCall request begin. Caller Uid: ${callInitiateRequest.callerUid} 
      Called Uid: ${callInitiateRequest.calledUid}`);

  // todo: call join request poor name as the caller isnt the joiner, also used for fcm not for this context

  const calledUid = callInitiateRequest.calledUid as string;
  const callerUid = callInitiateRequest.callerUid as string;
  const request = new CallJoinRequest({callerUid: callerUid, calledUid: calledUid});
  const callTransaction: CallTransaction = await createCallTransaction({request: request});
  const callerPrivateUserInfo: PrivateUserInfo = await getPrivateUserDocumentNoTransact({uid: callerUid});
  const paymentIntentClientSecret: string = await _createCallStartPaymentIntent(
      {callerPrivateUserInfo: callerPrivateUserInfo, callTransaction: callTransaction});
  const newClientCallState: CallerCallState = _createNewCallState(
      {callManager: clientCallManager, callTransaction: callTransaction,
        callJoinRequest: request, clientMessageSender: clientMessageSender});

  _listenForPaymentSuccess({callState: newClientCallState, callTransaction: callTransaction});
  _listenForCallTransactionUpdates({callState: newClientCallState, callTransaction: callTransaction});

  sendGrpcCallJoinOrRequestSuccess(callTransaction.callTransactionId, clientMessageSender);
  sendGrpcServerCallBeginPaymentInitiate(clientMessageSender, paymentIntentClientSecret,
      callerPrivateUserInfo.stripeCustomerId);
}

function _createNewCallState({callTransaction, callJoinRequest, clientMessageSender, callManager}:
  {callManager: CallManager, callTransaction: CallTransaction, callJoinRequest: CallJoinRequest,
  clientMessageSender: ClientMessageSenderInterface}): CallerCallState {
  const callBeginCallerContext = new CallerBeginCallContext({transactionId: callTransaction.callTransactionId,
    agoraChannelName: callTransaction.agoraChannelName, calledFcmToken: callTransaction.calledFcmToken,
    callJoinRequest: callJoinRequest});
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

async function _createCallStartPaymentIntent({callerPrivateUserInfo, callTransaction}:
  {callerPrivateUserInfo: PrivateUserInfo, callTransaction: CallTransaction}): Promise<string> {
  const [_, paymentIntentClientSecret] =
      await createStripePaymentIntent({customerId: callerPrivateUserInfo.stripeCustomerId,
        customerEmail: callerPrivateUserInfo.email, amountToBillInCents: callTransaction.expertRateCentsCallStart,
        paymentDescription: "Begin Call", paymentStatusId: callTransaction.callerCallStartPaymentStatusId,
        transferGroup: callTransaction.callerTransferGroup});
  return paymentIntentClientSecret;
}

