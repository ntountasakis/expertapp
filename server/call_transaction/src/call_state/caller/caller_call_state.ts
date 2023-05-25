import * as grpc from "@grpc/grpc-js";
import {CallerBeginCallContext} from "./caller_begin_call_context";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";
import {BaseCallState} from "../common/base_call_state";
import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";
import {getUtcMsSinceEpoch} from "../../../../functions/src/shared/src/general/utils";

export class CallerCallState extends BaseCallState {
  callerBeginCallContext: CallerBeginCallContext;
  _callJoinExpirationTimer?: NodeJS.Timeout;
  callJoinExpirationTimeUtcMs: number;
  callerFirstName: string;

  constructor({callerBeginCallContext, clientMessageSender, onDisconnect, userId, version, callStream, callerFirstName}:
    {
      callerBeginCallContext: CallerBeginCallContext, clientMessageSender: ClientMessageSenderInterface,
      onDisconnect: CallOnDisconnectInterface, userId: string, version: string,
      callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>,
      callerFirstName: string,
    }) {
    super({
      transactionId: callerBeginCallContext.transactionId, clientMessageSender: clientMessageSender,
      onDisconnect: onDisconnect, userId: userId, callStream: callStream, isCaller: true, version: version,
    });
    this.callerBeginCallContext = callerBeginCallContext;
    this._callJoinExpirationTimer = undefined;
    this.callJoinExpirationTimeUtcMs = 0;
    this.callerFirstName = callerFirstName;
  }

  async setCallJoinExpirationTimer(maxWaitTimeSec: number): Promise<void> {
    const currentMs = getUtcMsSinceEpoch();
    this.callJoinExpirationTimeUtcMs = currentMs + maxWaitTimeSec * 1000;
    await this.log(`Call join expiration timer started for ${maxWaitTimeSec} seconds for expiration at ${this.callJoinExpirationTimeUtcMs}`);
    this.setTimer(maxWaitTimeSec);
  }
}
