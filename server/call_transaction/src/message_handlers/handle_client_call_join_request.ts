import {sendGrpcServerAgoraCredentials} from "../server/client_communication/grpc/send_grpc_server_agora_credentials";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallJoinRequest} from "../protos/call_transaction_package/ClientCallJoinRequest";
import {joinCallTransaction} from "../firebase/firestore/functions/transaction/called/join_call_transaction";
import {CalledCallManager} from "../call_state/called/called_call_manager";
import {sendGrpcCallJoinOrRequestSuccess} from "../server/client_communication/grpc/send_grpc_call_join_or_request_success";
import {CallTransaction} from "../../../shared/src/firebase/firestore/models/call_transaction";
import {CalledCallState} from "../call_state/called/called_call_state";
import {onCalledTransactionUpdate} from "../call_events/called/called_on_transaction_update";
import {listenForCallTransactionUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_call_transaction_updates";
import {calledFinishCallTransaction} from "../call_events/called/called_finish_call_transaction";

export async function handleClientCallJoinRequest(callJoinRequest: ClientCallJoinRequest,
    clientMessageSender: ClientMessageSenderInterface,
    calledCallManager: CalledCallManager): Promise<void> {
  const transactionId = callJoinRequest.callTransactionId as string;
  const joinerId = callJoinRequest.joinerUid as string;
  console.log(`Got call join request from joinerId: ${joinerId} with transaction id: ${transactionId}`);

  const callTransaction: CallTransaction = await joinCallTransaction({request: callJoinRequest});

  const newCalledState: CalledCallState = _createNewCallState(
      {calledCallManager: calledCallManager, transactionId: transactionId,
        joinerId: joinerId, clientMessageSender: clientMessageSender});
  _listenForCallTransactionUpdates({callState: newCalledState, callTransaction: callTransaction});

  sendGrpcCallJoinOrRequestSuccess(transactionId, clientMessageSender);
  sendGrpcServerAgoraCredentials(clientMessageSender, callTransaction.agoraChannelName, joinerId);
}

function _createNewCallState({calledCallManager, transactionId, joinerId, clientMessageSender}:
  {calledCallManager: CalledCallManager, transactionId: string, joinerId: string,
  clientMessageSender: ClientMessageSenderInterface}): CalledCallState {
  return calledCallManager.createCallStateOnCallJoin({
    userId: joinerId, transactionId: transactionId,
    callerDisconnectFunction: calledFinishCallTransaction,
    clientMessageSender: clientMessageSender});
}

function _listenForCallTransactionUpdates({callState, callTransaction}:
  {callState: CalledCallState, callTransaction: CallTransaction}) {
  callState.eventListenerManager.listenForEventUpdates({key: callTransaction.callTransactionId,
    updateCallback: onCalledTransactionUpdate,
    unsubscribeFn: listenForCallTransactionUpdates(
        callState.transactionId, callState.eventListenerManager)});
}
