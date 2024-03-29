import * as grpc from "@grpc/grpc-js";
import {sendGrpcServerAgoraCredentials} from "../server/client_communication/grpc/send_grpc_server_agora_credentials";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallJoinRequest} from "../protos/call_transaction_package/ClientCallJoinRequest";
import {joinCallTransaction} from "../firebase/firestore/functions/transaction/called/join_call_transaction";
import {sendGrpcCallJoinOrRequestSuccess} from "../server/client_communication/grpc/send_grpc_call_join_or_request_success";
import {CalledCallState} from "../call_state/called/called_call_state";
import {onCalledTransactionUpdate} from "../call_events/called/called_on_transaction_update";
import {listenForCallTransactionUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_call_transaction_updates";
import {onCalledDisconnect} from "../call_events/called/on_called_disconnect";
import {CallManager} from "../call_state/common/call_manager";
import {sendGrpcServerFeeBreakdowns} from "../server/client_communication/grpc/send_grpc_server_fee_breakdowns";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../protos/call_transaction_package/ServerMessageContainer";
import {CallTransaction} from "../../../functions/src/shared/src/firebase/firestore/models/call_transaction";

export async function handleClientCallJoinRequest(callJoinRequest: ClientCallJoinRequest,
    clientMessageSender: ClientMessageSenderInterface,
    CallManager: CallManager, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>): Promise<void> {
  const transactionId = callJoinRequest.callTransactionId as string;
  const joinerId = callJoinRequest.joinerUid as string;
  const version = callJoinRequest.version as string;

  const [, callTransaction] = await joinCallTransaction({request: callJoinRequest});
  const newCalledState: CalledCallState = _createNewCallState(
      {
        callManager: CallManager, transactionId: transactionId,
        joinerId: joinerId, clientMessageSender: clientMessageSender, callStream: callStream, version: version,
      });

  await newCalledState.log(`Received ClientCallJoinRequest: ${JSON.stringify(callJoinRequest)}`);

  _listenForCallTransactionUpdates({callState: newCalledState, callTransaction: callTransaction});
  await _startMaxCallLengthTimer({callTransaction: callTransaction, calledCallState: newCalledState});

  sendGrpcCallJoinOrRequestSuccess(transactionId, callTransaction.maxCallTimeSec, clientMessageSender, newCalledState);
  await sendGrpcServerAgoraCredentials(clientMessageSender, callTransaction.agoraChannelName, joinerId, newCalledState);
  sendGrpcServerFeeBreakdowns(clientMessageSender, callTransaction, newCalledState);
}

function _createNewCallState({callManager, transactionId, joinerId, clientMessageSender, callStream, version}:
  {
    callManager: CallManager, transactionId: string, joinerId: string, version: string,
    clientMessageSender: ClientMessageSenderInterface,
    callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>
  }): CalledCallState {
  return callManager.createCallStateOnCallJoin({
    userId: joinerId, transactionId: transactionId,
    disconnectionFunction: onCalledDisconnect,
    clientMessageSender: clientMessageSender, callStream: callStream, version: version,
  });
}

function _listenForCallTransactionUpdates({callState, callTransaction}:
  { callState: CalledCallState, callTransaction: CallTransaction }) {
  callState.eventListenerManager.listenForEventUpdates({
    key: callTransaction.callTransactionId,
    updateCallback: onCalledTransactionUpdate,
    unsubscribeFn: listenForCallTransactionUpdates(callState),
  });
}

async function _startMaxCallLengthTimer({callTransaction, calledCallState}: { callTransaction: CallTransaction, calledCallState: CalledCallState }) {
  await calledCallState.setMaxCallLengthTimer(callTransaction.maxCallTimeSec);
}
