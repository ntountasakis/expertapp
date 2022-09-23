import {CallerCallState} from "../../call_state/caller/caller_call_state";
import {BaseCallState} from "../../call_state/common/base_call_state";
// eslint-disable-next-line max-len
import {listenForPaymentStatusUpdates} from "../../firebase/firestore/event_listeners/model_listeners/listen_for_payment_status_updates";
// eslint-disable-next-line max-len
import {endCallTransactionCallerUninitiated} from "../../firebase/firestore/functions/transaction/caller/end_call_transaction_caller_uninitiated";
// eslint-disable-next-line max-len
import {EndCallTransactionReturnType} from "../../firebase/firestore/functions/transaction/types/call_transaction_types";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
// eslint-disable-next-line max-len
import {sendGrpcServerCallTerminatePaymentInitiate} from "../../server/client_communication/grpc/send_grpc_server_call_terminate_payment_initiate";
import {onCallerPaymentSuccessCallTerminate} from "./caller_on_payment_success_call_terminate";

export async function callerSendPaymentRequestEndOfCall(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState): Promise<void> {
  const callerCallState = callState as CallerCallState;
  if (callerCallState.hasInitiatedCallTerminatePayment) {
    console.log(`Suppressing payment request for ${callState.transactionId} to client on end of call.`);
    return;
  }
  callerCallState.hasInitiatedCallTerminatePayment = true;

  console.log(`Sending payment request for ${callState.transactionId} to client on end of call.`);
  const endCallPromise: EndCallTransactionReturnType =
        await endCallTransactionCallerUninitiated({transactionId: callState.transactionId});

  if (typeof endCallPromise === "string") {
    console.error(endCallPromise);
    return;
  }

  const [, endCallPaymentIntentClientSecret,
    endCallPaymentStatusId, callerStripeCustomerId] = endCallPromise;
  sendGrpcServerCallTerminatePaymentInitiate({clientMessageSender: clientMessageSender,
    customerId: callerStripeCustomerId, clientSecret: endCallPaymentIntentClientSecret});

  callState.eventListenerManager.listenForEventUpdates({key: endCallPaymentStatusId,
    updateCallback: onCallerPaymentSuccessCallTerminate,
    unsubscribeFn: listenForPaymentStatusUpdates(
        endCallPaymentStatusId, callState.eventListenerManager)});
}
