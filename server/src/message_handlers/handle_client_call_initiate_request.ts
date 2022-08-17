import {CallTransctionRequestResult} from "../call_transaction_request_result";
import {createCallTransaction} from "../create_call_transaction";
import {sendCallJoinRequest} from "../firebase/fcm/fcm_token_sender";
import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {ServerCallRequestResponse} from "../protos/call_transaction_package/ServerCallRequestResponse";
import {sendServerAgoraCredentials} from "../agora/client_utils/send_server_agora_credentials";
import {sendServerCallBeginPaymentInitiate} from "../stripe/send_server_call_begin_payment_initiate";
import {EventListenerManager} from "../event_listeners/event_listener_manager";
import {PaymentStatusState} from "../call_state/payment_status_state";
import {onPaymentSuccessCallInitiate} from "../call_events/on_payment_success_call_initiate";

export async function handleClientCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    clientMessageSender: ClientMessageSenderInterface, eventListenerManager: EventListenerManager): Promise<void> {
  console.log(`InitiateCall request begin. Caller Uid: ${callInitiateRequest.callerUid} 
      Called Uid: ${callInitiateRequest.calledUid}`);

  const calledUid = callInitiateRequest.calledUid as string;
  const callerUid = callInitiateRequest.callerUid as string;
  const request = new CallJoinRequest({callerUid: callerUid, calledUid: calledUid});
  const callTransactionResult: CallTransctionRequestResult = await createCallTransaction({request: request});

  if (!callTransactionResult.success) {
    sendCallRequestFailure(`Unable to create call transaction. Error: ${callTransactionResult.errorMessage}`,
        clientMessageSender);
    return;
  }

  // todo: named params
  sendCallJoinRequest(callTransactionResult.calledFcmToken, request, callTransactionResult.callTransactionId);
  sendCallRequestSuccess(clientMessageSender);
  sendServerAgoraCredentials(clientMessageSender, callTransactionResult.agoraChannelName, callerUid);

  const paymentStatusState = new PaymentStatusState(clientMessageSender, onPaymentSuccessCallInitiate);
  eventListenerManager.registerForPaymentStatusUpdates(callTransactionResult.callerCallStartPaymentStatusId,
      paymentStatusState);

  sendServerCallBeginPaymentInitiate(clientMessageSender, callTransactionResult.stripeCallerClientSecret,
      callTransactionResult.stripeCallerCustomerId);
  return;
}

function sendCallRequestFailure(errorMessage: string,
    clientMessageSender: ClientMessageSenderInterface) {
  console.error(errorMessage);
  const serverCallRequestResponse: ServerCallRequestResponse = {
    "success": false,
    "errorMessage": errorMessage,
  };
  clientMessageSender.sendCallRequestResponse(serverCallRequestResponse);
}

function sendCallRequestSuccess(clientMessageSender: ClientMessageSenderInterface) {
  const serverCallRequestResponse: ServerCallRequestResponse = {
    "success": true,
    "errorMessage": "",
  };
  clientMessageSender.sendCallRequestResponse(serverCallRequestResponse);
}
