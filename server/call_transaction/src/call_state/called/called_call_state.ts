import * as grpc from "@grpc/grpc-js";
import { getUtcMsSinceEpoch } from "../../../../shared/src/general/utils";
import { ClientMessageSenderInterface } from "../../message_sender/client_message_sender_interface";
import { ClientMessageContainer } from "../../protos/call_transaction_package/ClientMessageContainer";
import { ServerMessageContainer } from "../../protos/call_transaction_package/ServerMessageContainer";
import { BaseCallState } from "../common/base_call_state";
import { CallOnDisconnectInterface } from "../functions/call_on_disconnect_interface";

export class CalledCallState extends BaseCallState {
  maxCallLengthTimer?: NodeJS.Timeout;

  constructor({ transactionId, clientMessageSender, onDisconnect, userId, version, callStream }:
    {
      transactionId: string, clientMessageSender: ClientMessageSenderInterface,
      onDisconnect: CallOnDisconnectInterface,
      userId: string, version: string, callStream: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>
    }) {
    super({
      transactionId: transactionId, clientMessageSender: clientMessageSender, onDisconnect: onDisconnect, userId: userId,
      callStream: callStream, isCaller: false, version: version,
    })
    this.maxCallLengthTimer = undefined;
  }

  async setMaxCallLengthTimer(maxCallTimeSec: number): Promise<void> {
    await this.log(`Max call length started for ${maxCallTimeSec * 1000} ms at ${getUtcMsSinceEpoch()}`);
    this.setTimer(maxCallTimeSec);
  }
}
