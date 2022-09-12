import * as grpc from "@grpc/grpc-js";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallBeginPaymentInitiate} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiate";
// eslint-disable-next-line max-len
import {ServerCallBeginPaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";
import {ServerCallRequestResponse} from "../protos/call_transaction_package/ServerCallRequestResponse";
import { ServerCallTerminatePaymentInitiate } from "../protos/call_transaction_package/ServerCallTerminatePaymentInitiate";
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
        "serverCallRequestResponse": callRequestResponse,
        "messageWrapper": "serverCallRequestResponse",
      };
      this.sendingStream.write(clientMessageContainer);
    }
    sendCallAgoraCredentials(callAgoraCredentials: ServerAgoraCredentials): void {
      const clientMessageContainer: ServerMessageContainer = {
        "serverAgoraCredentials": callAgoraCredentials,
        "messageWrapper": "serverAgoraCredentials",
      };
      this.sendingStream.write(clientMessageContainer);
    }
    sendCallBeginPaymentInitiate(callBeginPaymentInitiate: ServerCallBeginPaymentInitiate): void {
      const clientMessageContainer: ServerMessageContainer = {
        "serverCallBeginPaymentInitiate": callBeginPaymentInitiate,
        "messageWrapper": "serverCallBeginPaymentInitiate",
      };
      this.sendingStream.write(clientMessageContainer);
    }
    sendCallBeginPaymentInitiateResolved(
        callBeginPaymentInitiateResolved: ServerCallBeginPaymentInitiateResolved): void {
      const clientMessageContainer: ServerMessageContainer = {
        "serverCallBeginPaymentInitiateResolved": callBeginPaymentInitiateResolved,
        "messageWrapper": "serverCallBeginPaymentInitiateResolved",
      };
      this.sendingStream.write(clientMessageContainer);
    }
    sendCallTerminatePaymentInitiate(callTerminatePaymentInitiate: ServerCallTerminatePaymentInitiate):
      void {
      const clientMessageContainer: ServerMessageContainer = {
        "serverCallTerminatePaymentInitiate": callTerminatePaymentInitiate,
        "messageWrapper": "serverCallTerminatePaymentInitiate",
      };
      this.sendingStream.write(clientMessageContainer);
    }
}
