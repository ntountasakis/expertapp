import {sendGrpcServerAgoraCredentials} from "../server/client_communication/grpc/send_grpc_server_agora_credentials";
import {lookupAgoraChannelName} from "../firebase/firestore/functions/lookup_agora_channel_name";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallJoinRequest} from "../protos/call_transaction_package/ClientCallJoinRequest";
import {joinCallTransaction} from "../firebase/firestore/functions/join_call_transaction";

export async function handleClientCallJoinRequest(callJoinRequest: ClientCallJoinRequest,
    clientMessageSender: ClientMessageSenderInterface): Promise<void> {
  const transactionId = callJoinRequest.callTransactionId as string;
  const joinerId = callJoinRequest.joinerUid as string;
  console.log(`Got call join request from joinerId: ${joinerId} with transaction id: ${transactionId}`);

  const [joinCallValid, _] = await joinCallTransaction({request: callJoinRequest});

  if (!joinCallValid) {
    return;
  }

  // todo: put into joinCallTransactionFunction as duplicate checks and not transactional
  const [agoraChannelLookupSuccess, agoraChannelLookupErrorMessage, agoraChannelName] = await lookupAgoraChannelName(
      {callTransactionId: transactionId});

  if (!agoraChannelLookupSuccess) {
    console.error(agoraChannelLookupErrorMessage);
    return;
  }
  sendGrpcServerAgoraCredentials(clientMessageSender, agoraChannelName, joinerId);
}
