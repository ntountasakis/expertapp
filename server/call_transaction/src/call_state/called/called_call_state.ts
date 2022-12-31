import * as grpc from "@grpc/grpc-js";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";
import {BaseCallState} from "../common/base_call_state";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";

export class CalledCallState extends BaseCallState {
  hasInitiatedCallFinish: boolean;
  maxCallLengthTimer?: NodeJS.Timeout;

  constructor({transactionId, clientMessageSender, onDisconnect, userId, callStream}:
    {transactionId: string, clientMessageSender: ClientMessageSenderInterface,
      onDisconnect: CallOnDisconnectInterface,
      userId: string, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>}) {
    super({transactionId: transactionId, clientMessageSender: clientMessageSender, onDisconnect: onDisconnect, userId: userId,
      callStream: callStream});
    this.hasInitiatedCallFinish = false;
    this.maxCallLengthTimer = undefined;
  }

  setMaxCallLengthTimer(maxCallTimeSec: number): void {
    this.maxCallLengthTimer = setTimeout(this._maxCallLengthReached.bind(this), maxCallTimeSec * 1000);
    console.log(`Max call length started for ${maxCallTimeSec * 1000} ms at ${Date.now()}`);
  }

  cancelMaxCallLengthTimer(): void {
    if (this.maxCallLengthTimer !== undefined) {
      clearTimeout(this.maxCallLengthTimer);
    }
  }

  _maxCallLengthReached(): void {
    console.log("Max call length timer went off. Disconnecting");
    this.callStream.end();
  }
}
