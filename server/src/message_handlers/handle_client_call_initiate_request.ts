import {CallTransctionRequestResult} from "../call_transaction_request_result";
import {createCallTransaction} from "../create_call_transaction";
import {sendCallJoinRequest} from "../firebase/fcm/fcm_token_sender";
import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {ServerCallRequestResponse} from "../protos/call_transaction_package/ServerCallRequestResponse";
import {RtcTokenBuilder, Role} from "../agora/lib/RtcTokenBuilder";
import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {AgoraAppConfiguration} from "../agora/agora_app_configuration";
import {agoraGenerateChannelUid} from "../agora/agora_channel_utils";

export async function handleClientCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    clientMessageSender: ClientMessageSenderInterface): Promise<void> {
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


function sendServerAgoraCredentials(clientMessageSender: ClientMessageSenderInterface,
    channelName: string, clientUserId: string) {
  const agoraUidForChannel = agoraGenerateChannelUid();
  // todo TTL
  const token = RtcTokenBuilder.buildTokenWithUid(
      AgoraAppConfiguration.appID, AgoraAppConfiguration.appCert, channelName,
      agoraUidForChannel, Role.PUBLISHER, 0
  );
  const serverAgoraCredentials: ServerAgoraCredentials = {
    "token": token,
    "channelName": channelName,
    "uid": agoraUidForChannel,
  };
  console.log(`Generated AgoraToken: ${token} AgoraUid: ${agoraUidForChannel} 
  for channelName: ${channelName} and userId ${clientUserId}`);
  clientMessageSender.sendCallAgoraCredentials(serverAgoraCredentials);
}
