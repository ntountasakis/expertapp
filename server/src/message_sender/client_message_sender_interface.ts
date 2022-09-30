import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallJoinOrRequestResponse} from "../protos/call_transaction_package/ServerCallJoinOrRequestResponse";
import {ServerCallBeginPaymentInitiate} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiate";

import {ServerCallTerminatePaymentInitiate} from "../protos/call_transaction_package/ServerCallTerminatePaymentInitiate";

import {ServerCallBeginPaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentInitiateResolved";

import {ServerCallTerminatePaymentInitiateResolved} from "../protos/call_transaction_package/ServerCallTerminatePaymentInitiateResolved";
import {ServerCounterpartyJoinedCall} from "../protos/call_transaction_package/ServerCounterpartyJoinedCall";
import {ServerCounterpartyLeftCall} from "../protos/call_transaction_package/ServerCounterpartyLeftCall";

export abstract class ClientMessageSenderInterface {
    abstract sendCallJoinOrRequestResponse(callJoinOrRequestResponse: ServerCallJoinOrRequestResponse): void;
    abstract sendCallAgoraCredentials(callAgoraCredentials: ServerAgoraCredentials): void;
    abstract sendCallBeginPaymentInitiate(callBeginPaymentInitiate: ServerCallBeginPaymentInitiate): void;

    abstract sendCallBeginPaymentInitiateResolved(
        callBeginPaymentInitiateResolved: ServerCallBeginPaymentInitiateResolved): void;
    abstract sendCallTerminatePaymentInitiate(callTerminatePaymentInitiate: ServerCallTerminatePaymentInitiate): void;

    abstract sendCallTerminatePaymentInitiateResolved(
        callTerminatePaymentInitiateResolved: ServerCallTerminatePaymentInitiateResolved): void;

    abstract sendCounterpartyJoinedCall(counterpartyJoinedCall: ServerCounterpartyJoinedCall): void;
    abstract sendCounterpartyLeftCall(sendCounterpartyLeftCall: ServerCounterpartyLeftCall): void;
}
