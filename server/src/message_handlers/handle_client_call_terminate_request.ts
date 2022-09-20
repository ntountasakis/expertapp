// eslint-disable-next-line max-len
import {onPaymentSuccessCallTerminate} from "../call_events/on_payment_success_call_terminate";
import {CallerCallManager} from "../call_state/caller/caller_call_manager";
// eslint-disable-next-line max-len
import {endCallTransactionClientInitiated, EndCallTransactionReturnType} from "../firebase/firestore/functions/end_call_transaction_client_initiated";
import {listenForPaymentStatusUpdates} from "../firebase/firestore/functions/listen_for_payment_status_updates";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallTerminateRequest} from "../protos/call_transaction_package/ClientCallTerminateRequest";
// eslint-disable-next-line max-len
import {sendGrpcServerCallTerminatePaymentInitiate} from "../server/client_communication/grpc/send_grpc_server_call_terminate_payment_initiate";

export async function handleClientCallTerminateRequest(callTerminateRequest: ClientCallTerminateRequest,
    clientMessageSender: ClientMessageSenderInterface, clientCallManager: CallerCallManager): Promise<void> {
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

  const uid = callTerminateRequest.uid as string;
  const existingClientCallState = clientCallManager.getCallState({userId: uid});
  if (existingClientCallState === undefined) {
    console.error(`Cannot find existing CallState in handleClientCallTerminateRequest for ID: ${endCallTransactionId}`);
    return;
  }
  existingClientCallState.eventListenerManager.listenForEventUpdates({key: endCallPaymentStatusId,
    updateCallback: onPaymentSuccessCallTerminate,
    unsubscribeFn: listenForPaymentStatusUpdates(
        endCallPaymentStatusId, existingClientCallState.eventListenerManager)});
}
