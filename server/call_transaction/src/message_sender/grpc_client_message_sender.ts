import * as grpc from "@grpc/grpc-js";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallBeginPaymentPreAuth} from "../protos/call_transaction_package/ServerCallBeginPaymentPreAuth";
import {ServerCallBeginPaymentPreAuthResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentPreAuthResolved";
import {ServerCallJoinOrRequestResponse} from "../protos/call_transaction_package/ServerCallJoinOrRequestResponse";
import {ServerCounterpartyJoinedCall} from "../protos/call_transaction_package/ServerCounterpartyJoinedCall";
import {ServerFeeBreakdowns} from "../protos/call_transaction_package/ServerFeeBreakdowns";
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
  sendCallBeginPaymentPreAuth(callBeginPaymentPreAuth: ServerCallBeginPaymentPreAuth): void {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallBeginPaymentPreAuth": callBeginPaymentPreAuth,
      "messageWrapper": "serverCallBeginPaymentPreAuth",
    };
    this.sendingStream.write(clientMessageContainer);
  }

  sendCallBeginPaymentPreAuthResolved(callBeginPaymentPreAuthResolved: ServerCallBeginPaymentPreAuthResolved): void {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallBeginPaymentPreAuthResolved": callBeginPaymentPreAuthResolved,
      "messageWrapper": "serverCallBeginPaymentPreAuthResolved",
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

  sendServerFeeBreakdowns(feeBreakdowns: ServerFeeBreakdowns): void {
    const clientMessageContainer: ServerMessageContainer = {
      "serverFeeBreakdowns": feeBreakdowns,
      "messageWrapper": "serverFeeBreakdowns",
    };
    this.sendingStream.write(clientMessageContainer);
  }
}
