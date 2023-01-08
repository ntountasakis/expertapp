import * as grpc from "@grpc/grpc-js";
import {ClientMessageContainer} from "../protos/call_transaction_package/ClientMessageContainer";
import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallBeginPaymentPreAuth} from "../protos/call_transaction_package/ServerCallBeginPaymentPreAuth";
import {ServerCallBeginPaymentPreAuthResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentPreAuthResolved";
import {ServerCallJoinOrRequestResponse} from "../protos/call_transaction_package/ServerCallJoinOrRequestResponse";
import {ServerCallSummary} from "../protos/call_transaction_package/ServerCallSummary";
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
  async sendCallJoinOrRequestResponse(callRequestResponse: ServerCallJoinOrRequestResponse): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallJoinOrRequestResponse": callRequestResponse,
      "messageWrapper": "serverCallJoinOrRequestResponse",
    };
    await this.writeWrapper(clientMessageContainer);
  }
  async sendCallAgoraCredentials(callAgoraCredentials: ServerAgoraCredentials): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverAgoraCredentials": callAgoraCredentials,
      "messageWrapper": "serverAgoraCredentials",
    };
    await this.writeWrapper(clientMessageContainer);
  }
  async sendCallBeginPaymentPreAuth(callBeginPaymentPreAuth: ServerCallBeginPaymentPreAuth): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallBeginPaymentPreAuth": callBeginPaymentPreAuth,
      "messageWrapper": "serverCallBeginPaymentPreAuth",
    };
    await this.writeWrapper(clientMessageContainer);
  }

  async sendCallBeginPaymentPreAuthResolved(callBeginPaymentPreAuthResolved: ServerCallBeginPaymentPreAuthResolved): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallBeginPaymentPreAuthResolved": callBeginPaymentPreAuthResolved,
      "messageWrapper": "serverCallBeginPaymentPreAuthResolved",
    };
    await this.writeWrapper(clientMessageContainer);
  }

  async sendCounterpartyJoinedCall(counterpartyJoinedCall: ServerCounterpartyJoinedCall): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCounterpartyJoinedCall": counterpartyJoinedCall,
      "messageWrapper": "serverCounterpartyJoinedCall",
    };
    await this.writeWrapper(clientMessageContainer);
  }

  async sendServerFeeBreakdowns(feeBreakdowns: ServerFeeBreakdowns): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverFeeBreakdowns": feeBreakdowns,
      "messageWrapper": "serverFeeBreakdowns",
    };
    await this.writeWrapper(clientMessageContainer);
  }

  async sendCallSummary(callSummary: ServerCallSummary): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallSummary": callSummary,
      "messageWrapper": "serverCallSummary",
    };
    await this.writeWrapper(clientMessageContainer);
  }

  writeWrapper(messageContainer: ServerMessageContainer): Promise<void> {
    return new Promise((resolve, reject) => {
      this.write(messageContainer, (successResponse: any) => {
        resolve(successResponse);
      });
    });
  }

  write(messageContainer: ServerMessageContainer, cb: any) {
    if (!this.sendingStream.write(messageContainer)) {
      this.sendingStream.once("drain", cb);
    } else {
      process.nextTick(cb);
    }
  }
}
