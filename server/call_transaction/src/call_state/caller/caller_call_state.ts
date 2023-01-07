import * as grpc from "@grpc/grpc-js";
import {CallerBeginCallContext} from "./caller_begin_call_context";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {BaseCallState} from "../common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";
import {getUtcMsSinceEpoch} from "../../../../shared/src/general/utils";

export class CallerCallState extends BaseCallState {
  callerBeginCallContext: CallerBeginCallContext;
  hasInitiatedCallFinish: boolean;
  _callJoinExpirationTimer?: NodeJS.Timeout;
  callJoinExpirationTimeUtcMs: number;

  constructor({callerBeginCallContext, clientMessageSender, onDisconnect, userId, callStream}:
    {callerBeginCallContext: CallerBeginCallContext, clientMessageSender: ClientMessageSenderInterface,
      onDisconnect: CallOnDisconnectInterface, userId: string, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>}) {
    super({transactionId: callerBeginCallContext.transactionId, clientMessageSender: clientMessageSender,
      onDisconnect: onDisconnect, userId: userId, callStream: callStream});
    this.callerBeginCallContext = callerBeginCallContext;
    this.hasInitiatedCallFinish = false;
    this._callJoinExpirationTimer = undefined;
    this.callJoinExpirationTimeUtcMs = 0;
  }

  setCallJoinExpirationTimer(maxWaitTimeSec: number): void {
    const currentMs = getUtcMsSinceEpoch();
    this.callJoinExpirationTimeUtcMs = currentMs + maxWaitTimeSec * 1000;
    this.log(`Call join expiration timer started for ${maxWaitTimeSec} seconds for expiration at ${this.callJoinExpirationTimeUtcMs}`);
    this._callJoinExpirationTimer = setTimeout(this._callJoinExpirationTimerReached.bind(this), maxWaitTimeSec * 1000);
  }

  cancelCallJoinExpirationTimer(): void {
    if (this._callJoinExpirationTimer !== undefined) {
      this.log("Call join expiration timer cancelled");
      clearTimeout(this._callJoinExpirationTimer);
      this._callJoinExpirationTimer = undefined;
    }
  }

  async _callJoinExpirationTimerReached(): Promise<void> {
    this.log("Call join expiration timer went off marking call expired and disconnecting");
    this.callStream.end();
  }
}
