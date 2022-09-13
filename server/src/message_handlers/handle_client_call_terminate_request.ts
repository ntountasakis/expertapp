// eslint-disable-next-line max-len
import {onPaymentSuccessCallTerminate} from "../call_events/on_payment_success_call_terminate";
import {ClientCallManager} from "../call_state/client_call_manager";
import {PaymentStatusState} from "../call_state/payment_status_state";
import {EventListenerManager} from "../event_listeners/event_listener_manager";
// eslint-disable-next-line max-len
import {endCallTransactionClientInitiated, EndCallTransactionReturnType} from "../firebase/firestore/functions/end_call_transaction_client_initiated";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallTerminateRequest} from "../protos/call_transaction_package/ClientCallTerminateRequest";
// eslint-disable-next-line max-len
import {sendGrpcServerCallTerminatePaymentInitiate} from "../server/client_communication/grpc/send_grpc_server_call_terminate_payment_initiate";

export async function handleClientCallTerminateRequest(callTerminateRequest: ClientCallTerminateRequest,
    clientMessageSender: ClientMessageSenderInterface, clientCallManager: ClientCallManager,
    eventListenerManager: EventListenerManager): Promise<void> {
  // todo: use return values
  const endCallPromise: EndCallTransactionReturnType =
    await endCallTransactionClientInitiated({terminateRequest: callTerminateRequest});

  if (typeof endCallPromise === "string") {
    console.error(endCallPromise);
    return;
  }

  const [endCallTransactionId, endCallPaymentIntentClientSecret,
    endCallPaymentStatusId, callerStripeCustomerId] = endCallPromise;
  sendGrpcServerCallTerminatePaymentInitiate({clientMessageSender: clientMessageSender,
    customerId: callerStripeCustomerId, clientSecret: endCallPaymentIntentClientSecret});

  const existingClientCallState = clientCallManager.getCallState(endCallTransactionId);
  if (existingClientCallState === undefined) {
    console.error(`Cannot find existing CallState in handleClientCallTerminateRequest for ID: ${endCallTransactionId}`);
    return;
  }
  const paymentStatusState = new PaymentStatusState(clientMessageSender, existingClientCallState,
      onPaymentSuccessCallTerminate);
  eventListenerManager.registerForPaymentStatusUpdates(endCallPaymentStatusId, paymentStatusState);
}
