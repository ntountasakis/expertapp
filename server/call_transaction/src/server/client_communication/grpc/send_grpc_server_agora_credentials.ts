import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {AgoraAppConfiguration} from "../../../agora/agora_app_configuration";
import {agoraGenerateChannelUid} from "../../../agora/agora_channel_utils";
import {Role, RtcTokenBuilder} from "../../../agora/lib/RtcTokenBuilder";
import {ServerAgoraCredentials} from "../../../protos/call_transaction_package/ServerAgoraCredentials";

export function sendGrpcServerAgoraCredentials(clientMessageSender: ClientMessageSenderInterface,
    channelName: string, clientUserId: string): void {
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
