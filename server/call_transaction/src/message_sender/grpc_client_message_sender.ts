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
import {BaseCallState} from "../call_state/common/base_call_state";
import {ServerBothPartiesReadyForCall} from "../protos/call_transaction_package/ServerBothPartiesReadyForCall";

export class GrpcClientMessageSender extends ClientMessageSenderInterface {
  sendingStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>;

  constructor(sendingStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>) {
    super();
    this.sendingStream = sendingStream;
  }
  async sendCallJoinOrRequestResponse(callRequestResponse: ServerCallJoinOrRequestResponse, callState: BaseCallState): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallJoinOrRequestResponse": callRequestResponse,
      "messageWrapper": "serverCallJoinOrRequestResponse",
    };
    await this.writeWrapper(clientMessageContainer);
    await callState.log("Sent ServerCallJoinOrRequestResponse: " + JSON.stringify(callRequestResponse));
  }
  async sendCallAgoraCredentials(callAgoraCredentials: ServerAgoraCredentials, callState: BaseCallState): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverAgoraCredentials": callAgoraCredentials,
      "messageWrapper": "serverAgoraCredentials",
    };
    await this.writeWrapper(clientMessageContainer);
    await callState.log("Sent ServerAgoraCredentials: " + JSON.stringify(callAgoraCredentials));
  }
  async sendCallBeginPaymentPreAuth(callBeginPaymentPreAuth: ServerCallBeginPaymentPreAuth, callState: BaseCallState): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallBeginPaymentPreAuth": callBeginPaymentPreAuth,
      "messageWrapper": "serverCallBeginPaymentPreAuth",
    };
    await this.writeWrapper(clientMessageContainer);
    await callState.log("Sent ServerCallBeginPaymentPreAuth: " + JSON.stringify(callBeginPaymentPreAuth));
  }

  async sendCallBeginPaymentPreAuthResolved(callBeginPaymentPreAuthResolved: ServerCallBeginPaymentPreAuthResolved, callState: BaseCallState): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallBeginPaymentPreAuthResolved": callBeginPaymentPreAuthResolved,
      "messageWrapper": "serverCallBeginPaymentPreAuthResolved",
    };
    await this.writeWrapper(clientMessageContainer);
    await callState.log("Sent ServerCallBeginPaymentPreAuthResolved: " + JSON.stringify(callBeginPaymentPreAuthResolved));
  }

  async sendCounterpartyJoinedCall(counterpartyJoinedCall: ServerCounterpartyJoinedCall, callState: BaseCallState): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCounterpartyJoinedCall": counterpartyJoinedCall,
      "messageWrapper": "serverCounterpartyJoinedCall",
    };
    await this.writeWrapper(clientMessageContainer);
    await callState.log("Sent ServerCounterpartyJoinedCall: " + JSON.stringify(counterpartyJoinedCall));
  }

  async sendServerFeeBreakdowns(feeBreakdowns: ServerFeeBreakdowns, callState: BaseCallState): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverFeeBreakdowns": feeBreakdowns,
      "messageWrapper": "serverFeeBreakdowns",
    };
    await this.writeWrapper(clientMessageContainer);
    await callState.log("Sent ServerFeeBreakdowns: " + JSON.stringify(feeBreakdowns));
  }

  async sendCallSummary(callSummary: ServerCallSummary, callState: BaseCallState): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverCallSummary": callSummary,
      "messageWrapper": "serverCallSummary",
    };
    await this.writeWrapper(clientMessageContainer);
    await callState.log("Sent ServerCallSummary: " + JSON.stringify(callSummary));
  }

  async sendServerBothPartiesReadyForCall(callReady: ServerBothPartiesReadyForCall, callState: BaseCallState): Promise<void> {
    const clientMessageContainer: ServerMessageContainer = {
      "serverBothPartiesReadyForCall": callReady,
      "messageWrapper": "serverBothPartiesReadyForCall",
    };
    await this.writeWrapper(clientMessageContainer);
    await callState.log("Sent ServerBothPartiesReadyForCall: " + JSON.stringify(callReady));
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
