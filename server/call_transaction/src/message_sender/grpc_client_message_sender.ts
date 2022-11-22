import * as grpc from "@grpc/grpc-js";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallBeginPaymentInitiate} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiate";

import {ServerCallBeginPaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";
import {ServerCallJoinOrRequestResponse} from "../protos/call_transaction_package/ServerCallJoinOrRequestResponse";

import {ServerCallTerminatePaymentInitiate} from "../protos/call_transaction_package/ServerCallTerminatePaymentInitiate";

import {ServerCallTerminatePaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallTerminatePaymentInitiateResolved";
import {ServerCounterpartyJoinedCall} from "../protos/call_transaction_package/ServerCounterpartyJoinedCall";
import {ServerCounterpartyLeftCall} from "../protos/call_transaction_package/ServerCounterpartyLeftCall";
import {ServerMessageContainer} from "../protos/call_transaction_package/ServerMessageContainer";
import {ClientMessageSenderInterface} from "./client_message_sender_interface";

export class GrpcClientMessageSender extends ClientMessageSenderInterface {
  sendingStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>;

  constructor(sendingStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>) {
    super();
    this.sendingStream = sendingStream;
  }
  sendCallJoinOrRequestResponse(callRequestResponse: ServerCallJoinOrRequestResponse): void {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallJoinOrRequestResponse": callRequestResponse,
      "messageWrapper": "serverCallJoinOrRequestResponse",
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
  sendCallTerminatePaymentInitiateResolved(
      callTerminatePaymentInitiateResolved: ServerCallTerminatePaymentInitiateResolved): void {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallTerminatePaymentInitiateResolved": callTerminatePaymentInitiateResolved,
      "messageWrapper": "serverCallTerminatePaymentInitiateResolved",
    };
    this.sendingStream.write(clientMessageContainer);
  }

  sendCounterpartyJoinedCall(counterpartyJoinedCall: ServerCounterpartyJoinedCall): void {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCounterpartyJoinedCall": counterpartyJoinedCall,
      "messageWrapper": "serverCounterpartyJoinedCall",
    };
    this.sendingStream.write(clientMessageContainer);
  }

  sendCounterpartyLeftCall(counterpartyLeftCall: ServerCounterpartyLeftCall): void {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCounterpartyLeftCall": counterpartyLeftCall,
      "messageWrapper": "serverCounterpartyLeftCall",
    };
    this.sendingStream.write(clientMessageContainer);
  }
}
