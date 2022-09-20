import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallRequestResponse} from "../protos/call_transaction_package/ServerCallRequestResponse";
import {ServerCallBeginPaymentInitiate} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiate";
// eslint-disable-next-line max-len
import {ServerCallTerminatePaymentInitiate} from "../protos/call_transaction_package/ServerCallTerminatePaymentInitiate";
// eslint-disable-next-line max-len
import {ServerCallBeginPaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";
// eslint-disable-next-line max-len
import {ServerCallTerminatePaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallTerminatePaymentInitiateResolved";
import {ServerCounterpartyJoinedCall} from "../protos/call_transaction_package/ServerCounterpartyJoinedCall";
import {ServerCounterpartyLeftCall} from "../protos/call_transaction_package/ServerCounterpartyLeftCall";

export abstract class ClientMessageSenderInterface {
    abstract sendCallRequestResponse(callRequestResponse: ServerCallRequestResponse): void;
    abstract sendCallAgoraCredentials(callAgoraCredentials: ServerAgoraCredentials): void;
    abstract sendCallBeginPaymentInitiate(callBeginPaymentInitiate: ServerCallBeginPaymentInitiate): void;
    // eslint-disable-next-line max-len
    abstract sendCallBeginPaymentInitiateResolved(callBeginPaymentInitiateResolved: ServerCallBeginPaymentInitiateResolved): void;
    abstract sendCallTerminatePaymentInitiate(callTerminatePaymentInitiate: ServerCallTerminatePaymentInitiate): void;
    // eslint-disable-next-line max-len
    abstract sendCallTerminatePaymentInitiateResolved(callTerminatePaymentInitiateResolved: ServerCallTerminatePaymentInitiateResolved): void;

    abstract sendCounterpartyJoinedCall(counterpartyJoinedCall: ServerCounterpartyJoinedCall): void;
    abstract sendCounterpartyLeftCall(sendCounterpartyLeftCall: ServerCounterpartyLeftCall): void;
}
