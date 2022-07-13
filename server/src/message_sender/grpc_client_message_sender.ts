import * as grpc from "@grpc/grpc-js";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallRequestResponse} from "../protos/call_transaction_package/ServerCallRequestResponse";
import {ServerMessageContainer} from "../protos/call_transaction_package/ServerMessageContainer";
import {ClientMessageSenderInterface} from "./client_message_sender_interface";

export class GrpcClientMessageSender extends ClientMessageSenderInterface {
    sendingStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>;

    constructor(sendingStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>) {
      super();
      this.sendingStream = sendingStream;
    }
    sendCallRequestResponse(callRequestResponse: ServerCallRequestResponse): void {
      const clientMessageContainer: ServerMessageContainer = {
        "ServerCallRequestResponse": callRequestResponse,
        "messageWrapper": "ServerCallRequestResponse",
      };
      this.sendingStream.write(clientMessageContainer);
    }
    sendCallAgoraCredentials(callAgoraCredentials: ServerAgoraCredentials): void {
      const clientMessageContainer: ServerMessageContainer = {
        "serverAgoraCredentials": callAgoraCredentials,
        "messageWrapper": "ServerCallRequestResponse",
      };
      this.sendingStream.write(clientMessageContainer);
    }
}
