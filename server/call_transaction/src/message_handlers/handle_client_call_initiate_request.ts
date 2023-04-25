import * as grpc from "@grpc/grpc-js";
import {createCallTransaction} from "../firebase/firestore/functions/transaction/caller/create_call_transaction";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {onCallerPaymentPreAuthSuccessCallInitiate} from "../call_events/caller/caller_on_payment_pre_auth_success_call_initiate";
import {CallManager} from "../call_state/common/call_manager";

import {sendGrpcServerCallBeginPaymentInitiate} from "../server/client_communication/grpc/send_grpc_server_call_begin_payment_pre_auth";
import {sendGrpcCallJoinOrRequestSuccess} from "../server/client_communication/grpc/send_grpc_call_join_or_request_success";

import {onCallerTransactionUpdate} from "../call_events/caller/caller_on_transaction_update";

import {listenForPaymentStatusUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_payment_status_updates";

import {listenForCallTransactionUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_call_transaction_updates";
import {CallTransaction} from "../../../shared/src/firebase/firestore/models/call_transaction";
import {CallerCallState} from "../call_state/caller/caller_call_state";
import {CallerBeginCallContext} from "../call_state/caller/caller_begin_call_context";
import {ExpertRate} from "../../../shared/src/firebase/firestore/models/expert_rate";
import {sendGrpcServerFeeBreakdowns} from "../server/client_communication/grpc/send_grpc_server_fee_breakdowns";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../protos/call_transaction_package/ServerMessageContainer";
import {onCallerDisconnect} from "../call_events/caller/on_caller_disconnect";

export async function handleClientCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    clientMessageSender: ClientMessageSenderInterface, clientCallManager: CallManager,
    callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>): Promise<void> {
  const calledUid = callInitiateRequest.calledUid as string;
  const callerUid = callInitiateRequest.callerUid as string;
  const version = callInitiateRequest.version as string;

  const [didCreateCall, stripeCustomerId, paymentIntentClientSecret, ephemeralKey, centsRequestedAuth, optCallTransaction, optExpertRate] =
    await createCallTransaction({callerUid: callerUid, calledUid: calledUid});
  if (!didCreateCall) {
    return;
  }
  const callTransaction = optCallTransaction as CallTransaction;
  const expertRate = optExpertRate as ExpertRate;

  const newClientCallState: CallerCallState = await _createNewCallState({
    callManager: clientCallManager, callTransaction: callTransaction,
    calledUid: calledUid, callerUid: callerUid, expertRate: expertRate, clientMessageSender: clientMessageSender,
    callStream: callStream, version: version,
  });

  await newClientCallState.log(`Received ClientCallInitiateRequest: ${JSON.stringify(callInitiateRequest)}`);
  await newClientCallState.log(`Created caller call state. They called CalledUid: ${callInitiateRequest.calledUid}`);

  _listenForPaymentSuccess({callState: newClientCallState, callTransaction: callTransaction});
  _listenForCallTransactionUpdates({callState: newClientCallState, callTransaction: callTransaction});

  sendGrpcCallJoinOrRequestSuccess(callTransaction.callTransactionId, callTransaction.maxCallTimeSec, clientMessageSender, newClientCallState);
  sendGrpcServerCallBeginPaymentInitiate(clientMessageSender, paymentIntentClientSecret, ephemeralKey, stripeCustomerId,
      centsRequestedAuth, newClientCallState);
  sendGrpcServerFeeBreakdowns(clientMessageSender, callTransaction, newClientCallState);
}

async function _createNewCallState({callTransaction, callerUid, calledUid, expertRate, clientMessageSender, callManager, callStream, version}:
  {
    callManager: CallManager, callTransaction: CallTransaction, callerUid: string, calledUid: string,
    version: string, expertRate: ExpertRate, clientMessageSender: ClientMessageSenderInterface,
    callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>
  }): Promise<CallerCallState> {
  const callBeginCallerContext = new CallerBeginCallContext({
    transactionId: callTransaction.callTransactionId,
    agoraChannelName: callTransaction.agoraChannelName, calledFcmToken: callTransaction.calledFcmToken,
    callerUid: callerUid, calledUid: calledUid, expertRate: expertRate,
  });
  return await callManager.createCallStateOnCallerBegin({
    userId: callTransaction.callerUid, callerBeginCallContext: callBeginCallerContext,
    callerDisconnectFunction: onCallerDisconnect,
    clientMessageSender: clientMessageSender, callStream: callStream, version: version,
  });
}

function _listenForPaymentSuccess({callState, callTransaction}:
  { callState: CallerCallState, callTransaction: CallTransaction }) {
  callState.eventListenerManager.listenForEventUpdates({
    key: callTransaction.callerPaymentStatusId,
    updateCallback: onCallerPaymentPreAuthSuccessCallInitiate,
    unsubscribeFn: listenForPaymentStatusUpdates(callTransaction.callerPaymentStatusId, callState),
  });
}

function _listenForCallTransactionUpdates({callState, callTransaction}:
  { callState: CallerCallState, callTransaction: CallTransaction }) {
  callState.eventListenerManager.listenForEventUpdates({
    key: callTransaction.callTransactionId,
    updateCallback: onCallerTransactionUpdate,
    unsubscribeFn: listenForCallTransactionUpdates(callState),
  });
}
