import {sendGrpcServerAgoraCredentials} from "../server/client_communication/grpc/send_grpc_server_agora_credentials";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallJoinRequest} from "../protos/call_transaction_package/ClientCallJoinRequest";
import {joinCallTransaction} from "../firebase/firestore/functions/transaction/called/join_call_transaction";
import {CalledCallManager} from "../call_state/called/called_call_manager";

import {endCallTransactionClientDisconnect} from "../firebase/firestore/functions/transaction/common/end_call_transaction_client_disconnect";
import {onCalledTransactionUpdate} from "../call_events/called/called_on_transaction_update";

import {listenForCallTransactionUpdates} from "../firebase/firestore/event_listeners/model_listeners/listen_for_call_transaction_updates";
import {sendGrpcCallJoinOrRequestSuccess} from "../server/client_communication/grpc/send_grpc_call_join_or_request_success";
import {CallTransaction} from "../../../shared/firebase/firestore/models/call_transaction";
import {getCallTransactionDocument} from "../../../shared/firebase/firestore/document_fetchers/fetchers";

export async function handleClientCallJoinRequest(callJoinRequest: ClientCallJoinRequest,
    clientMessageSender: ClientMessageSenderInterface,
    calledCallManager: CalledCallManager): Promise<void> {
  const transactionId = callJoinRequest.callTransactionId as string;
  const joinerId = callJoinRequest.joinerUid as string;
  console.log(`Got call join request from joinerId: ${joinerId} with transaction id: ${transactionId}`);

  await joinCallTransaction({request: callJoinRequest});

  const newCalledState = calledCallManager.createCallStateOnCallJoin({
    userId: joinerId, transactionId: transactionId,
    callerDisconnectFunction: endCallTransactionClientDisconnect,
    clientMessageSender: clientMessageSender});
  newCalledState.eventListenerManager.listenForEventUpdates({key: transactionId,
    updateCallback: onCalledTransactionUpdate,
    unsubscribeFn: listenForCallTransactionUpdates(
        transactionId, newCalledState.eventListenerManager)});

  sendGrpcCallJoinOrRequestSuccess(transactionId, clientMessageSender);
  // todo: put into joinCallTransactionFunction as duplicate checks and not transactional
  const callTransaction: CallTransaction = await getCallTransactionDocument({transactionId: transactionId});
  if (callTransaction.agoraChannelName == "") {
    throw new Error(`No agora channel name for transaction: ${transactionId}`);
  }
  sendGrpcServerAgoraCredentials(clientMessageSender, callTransaction.agoraChannelName, joinerId);
}
