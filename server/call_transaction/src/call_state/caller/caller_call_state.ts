import * as grpc from "@grpc/grpc-js";
import {CallerBeginCallContext} from "./caller_begin_call_context";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {BaseCallState} from "../common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";
import endCallTransactionJoinTimerExpired from "../../firebase/firestore/functions/transaction/caller/end_call_transaction_join_timer_expired";

export class CallerCallState extends BaseCallState {
  callerBeginCallContext: CallerBeginCallContext;
  hasInitiatedCallFinish: boolean;
  _callJoinExpirationTimer?: NodeJS.Timeout;

  constructor({callerBeginCallContext, clientMessageSender, onDisconnect, userId, callStream}:
    {callerBeginCallContext: CallerBeginCallContext, clientMessageSender: ClientMessageSenderInterface,
      onDisconnect: CallOnDisconnectInterface, userId: string, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>}) {
    super({transactionId: callerBeginCallContext.transactionId, clientMessageSender: clientMessageSender,
      onDisconnect: onDisconnect, userId: userId, callStream: callStream});
    this.callerBeginCallContext = callerBeginCallContext;
    this.hasInitiatedCallFinish = false;
    this._callJoinExpirationTimer = undefined;
  }

  setCallJoinExpirationTimer(maxWaitTimeSec: number): void {
    console.log(`Call join expiration timer started for ${maxWaitTimeSec * 1000} ms at ${Date.now()}`);
    this._callJoinExpirationTimer = setTimeout(this._callJoinExpirationTimerReached.bind(this), maxWaitTimeSec * 1000);
  }

  cancelCallJoinExpirationTimer(): void {
    if (this._callJoinExpirationTimer !== undefined) {
      console.log("Call join expiration timer cancelled");
      clearTimeout(this._callJoinExpirationTimer);
    }
  }

  async _callJoinExpirationTimerReached(): Promise<void> {
    console.log("Call join expiration timer went off marking call expired and disconnecting");
    await endCallTransactionJoinTimerExpired({transactionId: this.transactionId});
    this.callStream.end();
  }
}
