import {createCallTransaction} from "../firebase/firestore/functions/transaction/caller/create_call_transaction";
import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {onCallerPaymentSuccessCallInitiate} from "../call_events/caller/caller_on_payment_success_call_initiate";
import {CallerCallManager} from "../call_state/caller/caller_call_manager";

import {sendGrpcServerCallBeginPaymentInitiate} from "../server/client_communication/grpc/send_grpc_server_call_begin_payment_initiate";
import {sendGrpcCallJoinOrRequestFailure} from "../server/client_communication/grpc/send_grpc_call_join_or_request_failure";
import {sendGrpcCallJoinOrRequestSuccess} from "../server/client_communication/grpc/send_grpc_call_join_or_request_success";
import {CallerBeginCallContext} from "../call_state/caller/caller_begin_call_context";

import {endCallTransactionClientDisconnect} from "../firebase/firestore/functions/transaction/common/end_call_transaction_client_disconnect";
import {onCallerTransactionUpdate} from "../call_events/caller/caller_on_transaction_update";

import {listenForPaymentStatusUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_payment_status_updates";

import {listenForCallTransactionUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_call_transaction_updates";


export async function handleClientCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    clientMessageSender: ClientMessageSenderInterface, clientCallManager: CallerCallManager): Promise<void> {
  console.log(`InitiateCall request begin. Caller Uid: ${callInitiateRequest.callerUid} 
      Called Uid: ${callInitiateRequest.calledUid}`);

  const calledUid = callInitiateRequest.calledUid as string;
  const callerUid = callInitiateRequest.callerUid as string;
  const request = new CallJoinRequest({callerUid: callerUid, calledUid: calledUid});
  const [transactionValid, transactionErrorMessage,
    callerPaymentIntentClientSecret, callerStripeCustomerId, transaction] =
    await createCallTransaction({request: request});

  if (!transactionValid || transaction == undefined) {
    sendGrpcCallJoinOrRequestFailure(`Unable to create call transaction. Error: ${transactionErrorMessage}`,
        clientMessageSender);
    return;
  }

  // todo: call join request poor name as the caller isnt the joiner
  // todo: named params

  const callBeginCallerContext = new CallerBeginCallContext({transactionId: transaction.callTransactionId,
    agoraChannelName: transaction.agoraChannelName, calledFcmToken: transaction.calledFcmToken,
    callJoinRequest: request});
  const newClientCallState = clientCallManager.createCallStateOnCallerBegin({
    userId: callerUid, callerBeginCallContext: callBeginCallerContext,
    callerDisconnectFunction: endCallTransactionClientDisconnect,
    clientMessageSender: clientMessageSender});
  newClientCallState.eventListenerManager.listenForEventUpdates({key: transaction?.callerCallStartPaymentStatusId,
    updateCallback: onCallerPaymentSuccessCallInitiate,
    unsubscribeFn: listenForPaymentStatusUpdates(
        transaction.callerCallStartPaymentStatusId, newClientCallState.eventListenerManager)});
  newClientCallState.eventListenerManager.listenForEventUpdates({key: transaction?.callTransactionId,
    updateCallback: onCallerTransactionUpdate,
    unsubscribeFn: listenForCallTransactionUpdates(
        transaction.callTransactionId, newClientCallState.eventListenerManager)});

  sendGrpcCallJoinOrRequestSuccess(transaction.callTransactionId, clientMessageSender);
  sendGrpcServerCallBeginPaymentInitiate(clientMessageSender, callerPaymentIntentClientSecret, callerStripeCustomerId);
}

