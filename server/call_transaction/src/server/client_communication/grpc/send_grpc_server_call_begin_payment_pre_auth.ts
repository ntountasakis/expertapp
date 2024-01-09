import {BaseCallState} from "../../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerCallBeginPaymentPreAuth} from "../../../protos/call_transaction_package/ServerCallBeginPaymentPreAuth";

export function sendGrpcServerCallBeginPaymentInitiate(clientMessageSender: ClientMessageSenderInterface,
    clientSecret: string, ephemeralKey: string, customerId: string, centsRequestedAuth: number, callState: BaseCallState): void {
  const serverCallBeginPaymentInitiate: ServerCallBeginPaymentPreAuth = {
    "clientSecret": clientSecret,
    "customerId": customerId,
    "ephemeralKey": ephemeralKey,
    "centsRequestedAuthorized": centsRequestedAuth,
  };
  clientMessageSender.sendCallBeginPaymentPreAuth(serverCallBeginPaymentInitiate, callState);
}
