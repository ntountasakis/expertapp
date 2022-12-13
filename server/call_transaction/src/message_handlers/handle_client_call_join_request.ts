import {sendGrpcServerAgoraCredentials} from "../server/client_communication/grpc/send_grpc_server_agora_credentials";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallJoinRequest} from "../protos/call_transaction_package/ClientCallJoinRequest";
import {joinCallTransaction} from "../firebase/firestore/functions/transaction/called/join_call_transaction";
import {sendGrpcCallJoinOrRequestSuccess} from "../server/client_communication/grpc/send_grpc_call_join_or_request_success";
import {CallTransaction} from "../../../shared/src/firebase/firestore/models/call_transaction";
import {CalledCallState} from "../call_state/called/called_call_state";
import {onCalledTransactionUpdate} from "../call_events/called/called_on_transaction_update";
import {listenForCallTransactionUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_call_transaction_updates";
import {calledFinishCallTransaction} from "../call_events/called/called_finish_call_transaction";
import {CallManager} from "../call_state/common/call_manager";
import {sendGrpcServerFeeBreakdowns} from "../server/client_communication/grpc/send_grpc_server_fee_breakdowns";

export async function handleClientCallJoinRequest(callJoinRequest: ClientCallJoinRequest,
    clientMessageSender: ClientMessageSenderInterface,
    CallManager: CallManager): Promise<boolean> {
  const transactionId = callJoinRequest.callTransactionId as string;
  const joinerId = callJoinRequest.joinerUid as string;
  console.log(`Got call join request from joinerId: ${joinerId} with transaction id: ${transactionId}`);

  const [allowedToJoin, callTransaction] = await joinCallTransaction({request: callJoinRequest});
  if (!allowedToJoin) {
    return false;
  }
  const newCalledState: CalledCallState = _createNewCallState(
      {CallManager: CallManager, transactionId: transactionId,
        joinerId: joinerId, clientMessageSender: clientMessageSender});
  _listenForCallTransactionUpdates({callState: newCalledState, callTransaction: callTransaction});

  sendGrpcCallJoinOrRequestSuccess(transactionId, clientMessageSender);
  sendGrpcServerAgoraCredentials(clientMessageSender, callTransaction.agoraChannelName, joinerId);
  sendGrpcServerFeeBreakdowns(clientMessageSender, callTransaction);
  return true;
}

function _createNewCallState({CallManager, transactionId, joinerId, clientMessageSender}:
  {CallManager: CallManager, transactionId: string, joinerId: string,
  clientMessageSender: ClientMessageSenderInterface}): CalledCallState {
  return CallManager.createCallStateOnCallJoin({
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
