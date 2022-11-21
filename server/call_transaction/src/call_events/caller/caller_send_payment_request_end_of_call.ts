import {CallTransaction} from "../../../../shared/src/firebase/firestore/models/call_transaction";
import {BaseCallState} from "../../call_state/common/base_call_state";
import {listenForPaymentStatusUpdates} from "../../firebase/firestore/event_listeners/model_listeners/listen_for_payment_status_updates";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {sendGrpcServerCallTerminatePaymentInitiate} from "../../server/client_communication/grpc/send_grpc_server_call_terminate_payment_initiate";
import {onCallerPaymentSuccessCallTerminate} from "./caller_on_payment_success_call_terminate";

export async function callerSendPaymentRequestEndOfCall({clientMessageSender, callState, callTransaction, paymentClientSecret, stripeCustomerId}:
  {clientMessageSender: ClientMessageSenderInterface, callState: BaseCallState, callTransaction: CallTransaction,
  paymentClientSecret: string, stripeCustomerId: string}): Promise<void> {
  console.log(`Sending payment request for ${callState.transactionId} to client on end of call.`);
  _listenForPaymentSuccess({callState, callTransaction});
  sendGrpcServerCallTerminatePaymentInitiate({clientMessageSender: clientMessageSender,
    customerId: stripeCustomerId, clientSecret: paymentClientSecret});
}

function _listenForPaymentSuccess({callState, callTransaction}:
  {callState: BaseCallState, callTransaction: CallTransaction}) {
  callState.eventListenerManager.listenForEventUpdates({key: callTransaction.callerCallTerminatePaymentStatusId,
    updateCallback: onCallerPaymentSuccessCallTerminate,
    unsubscribeFn: listenForPaymentStatusUpdates(
        callTransaction.callerCallTerminatePaymentStatusId, callState.eventListenerManager)});
}
