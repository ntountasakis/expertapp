import {getPrivateUserDocumentNoTransact} from "../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../shared/firebase/firestore/models/call_transaction";
import {PrivateUserInfo} from "../../../../shared/firebase/firestore/models/private_user_info";
import createStripePaymentIntent from "../../../../shared/stripe/payment_intent_creator";
import {BaseCallState} from "../../call_state/common/base_call_state";

import {listenForPaymentStatusUpdates} from "../../firebase/firestore/event_listeners/model_listeners/listen_for_payment_status_updates";

import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";

import {sendGrpcServerCallTerminatePaymentInitiate} from "../../server/client_communication/grpc/send_grpc_server_call_terminate_payment_initiate";
import {onCallerPaymentSuccessCallTerminate} from "./caller_on_payment_success_call_terminate";

export async function callerSendPaymentRequestEndOfCall(clientMessageSender: ClientMessageSenderInterface,
    callState: BaseCallState, callTransaction: CallTransaction): Promise<void> {
  const callerPrivateUserInfo: PrivateUserInfo = await getPrivateUserDocumentNoTransact(
      {uid: callTransaction.callerUid});
  const paymentIntentClientSecret: string = await _createCallTerminatePaymentIntent(
      {callerPrivateUserInfo: callerPrivateUserInfo, callTransaction: callTransaction});

  console.log(`Sending payment request for ${callState.transactionId} to client on end of call.`);
  _listenForPaymentSuccess({callState, callTransaction});
  sendGrpcServerCallTerminatePaymentInitiate({clientMessageSender: clientMessageSender,
    customerId: callerPrivateUserInfo.stripeCustomerId, clientSecret: paymentIntentClientSecret});
}

function _listenForPaymentSuccess({callState, callTransaction}:
  {callState: BaseCallState, callTransaction: CallTransaction}) {
  callState.eventListenerManager.listenForEventUpdates({key: callTransaction.callerCallTerminatePaymentStatusId,
    updateCallback: onCallerPaymentSuccessCallTerminate,
    unsubscribeFn: listenForPaymentStatusUpdates(
        callTransaction.callerCallTerminatePaymentStatusId, callState.eventListenerManager)});
}

async function _createCallTerminatePaymentIntent({callerPrivateUserInfo, callTransaction}:
  {callerPrivateUserInfo: PrivateUserInfo, callTransaction: CallTransaction}): Promise<string> {
  const [_, paymentIntentClientSecret] =
      await createStripePaymentIntent({customerId: callerPrivateUserInfo.stripeCustomerId,
        customerEmail: callerPrivateUserInfo.email, amountToBillInCents: callTransaction.callerFinalCostCallTerminate,
        paymentDescription: "End Call", paymentStatusId: callTransaction.callerCallTerminatePaymentStatusId,
        transferGroup: callTransaction.callerTransferGroup});
  return paymentIntentClientSecret;
}

