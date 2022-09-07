import {CallTransctionRequestResult} from "../call_transaction_request_result";
import {createCallTransaction} from "../create_call_transaction";
import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {EventListenerManager} from "../event_listeners/event_listener_manager";
import {PaymentStatusState} from "../call_state/payment_status_state";
import {onPaymentSuccessCallInitiate} from "../call_events/on_payment_success_call_initiate";
import {ClientCallManager} from "../call_state/client_call_manager";
// eslint-disable-next-line max-len
import {sendGrpcServerCallBeginPaymentInitiate} from "../server/client_communication/grpc/send_grpc_server_call_begin_payment_initiate";
import {sendGrpcCallRequestFailure} from "../server/client_communication/grpc/send_grpc_call_request_failure";
import {sendGrpcCallRequestSuccess} from "../server/client_communication/grpc/send_grpc_call_request_success";

export async function handleClientCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    clientMessageSender: ClientMessageSenderInterface, eventListenerManager: EventListenerManager,
    clientCallManager: ClientCallManager): Promise<void> {
  console.log(`InitiateCall request begin. Caller Uid: ${callInitiateRequest.callerUid} 
      Called Uid: ${callInitiateRequest.calledUid}`);

  const calledUid = callInitiateRequest.calledUid as string;
  const callerUid = callInitiateRequest.callerUid as string;
  const request = new CallJoinRequest({callerUid: callerUid, calledUid: calledUid});
  const callTransactionResult: CallTransctionRequestResult = await createCallTransaction({request: request});

  if (!callTransactionResult.success) {
    sendGrpcCallRequestFailure(`Unable to create call transaction. Error: ${callTransactionResult.errorMessage}`,
        clientMessageSender);
    return;
  }

  // todo: named params

  const newClientCallState = clientCallManager.createNewCallState(request, callTransactionResult);
  const paymentStatusState = new PaymentStatusState(clientMessageSender, newClientCallState,
      onPaymentSuccessCallInitiate);
  eventListenerManager.registerForPaymentStatusUpdates(callTransactionResult.callerCallStartPaymentStatusId,
      paymentStatusState);

  sendGrpcCallRequestSuccess(clientMessageSender);
  sendGrpcServerCallBeginPaymentInitiate(clientMessageSender, callTransactionResult.stripeCallerClientSecret,
      callTransactionResult.stripeCallerCustomerId);
  return;
}

