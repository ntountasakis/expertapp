import {createCallTransaction} from "../firebase/firestore/functions/create_call_transaction";
import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {PaymentStatusState} from "../call_state/payment_status_state";
import {onPaymentSuccessCallInitiate} from "../call_events/on_payment_success_call_initiate";
import {ClientCallManager} from "../call_state/client_call_manager";
// eslint-disable-next-line max-len
import {sendGrpcServerCallBeginPaymentInitiate} from "../server/client_communication/grpc/send_grpc_server_call_begin_payment_initiate";
import {sendGrpcCallRequestFailure} from "../server/client_communication/grpc/send_grpc_call_request_failure";
import {sendGrpcCallRequestSuccess} from "../server/client_communication/grpc/send_grpc_call_request_success";
import {CallerBeginCallContext} from "../call_state/callback_contexts/caller_begin_call_context";
// eslint-disable-next-line max-len
import {endCallTransactionClientDisconnect} from "../firebase/firestore/functions/end_call_transaction_client_disconnect";

export async function handleClientCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    clientMessageSender: ClientMessageSenderInterface, clientCallManager: ClientCallManager): Promise<void> {
  console.log(`InitiateCall request begin. Caller Uid: ${callInitiateRequest.callerUid} 
      Called Uid: ${callInitiateRequest.calledUid}`);

  const calledUid = callInitiateRequest.calledUid as string;
  const callerUid = callInitiateRequest.callerUid as string;
  const request = new CallJoinRequest({callerUid: callerUid, calledUid: calledUid});
  const [transactionValid, transactionErrorMessage,
    callerPaymentIntentClientSecret, callerStripeCustomerId, transaction] =
    await createCallTransaction({request: request});

  if (!transactionValid || transaction == undefined) {
    sendGrpcCallRequestFailure(`Unable to create call transaction. Error: ${transactionErrorMessage}`,
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
    callerDisconnectFunction: endCallTransactionClientDisconnect});
  const paymentStatusState = new PaymentStatusState(clientMessageSender, newClientCallState,
      onPaymentSuccessCallInitiate);
  newClientCallState.eventListenerManager.registerForPaymentStatusUpdates(transaction?.callerCallStartPaymentStatusId,
      paymentStatusState);

  sendGrpcCallRequestSuccess(transaction.callTransactionId, clientMessageSender);
  sendGrpcServerCallBeginPaymentInitiate(clientMessageSender, callerPaymentIntentClientSecret, callerStripeCustomerId);
  return;
}

