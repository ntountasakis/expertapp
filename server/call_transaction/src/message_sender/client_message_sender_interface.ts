import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallJoinOrRequestResponse} from "../protos/call_transaction_package/ServerCallJoinOrRequestResponse";
import {ServerCallBeginPaymentPreAuth} from "../protos/call_transaction_package/ServerCallBeginPaymentPreAuth";
import {ServerCallBeginPaymentPreAuthResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentPreAuthResolved";
import {ServerFeeBreakdowns} from "../protos/call_transaction_package/ServerFeeBreakdowns";
import {ServerCounterpartyJoinedCall} from "../protos/call_transaction_package/ServerCounterpartyJoinedCall";
import {ServerCounterpartyLeftCall} from "../protos/call_transaction_package/ServerCounterpartyLeftCall";

export abstract class ClientMessageSenderInterface {
    abstract sendCallJoinOrRequestResponse(callJoinOrRequestResponse: ServerCallJoinOrRequestResponse): void;
    abstract sendCallAgoraCredentials(callAgoraCredentials: ServerAgoraCredentials): void;
    abstract sendCallBeginPaymentPreAuth(callBeginPaymentPreAuth: ServerCallBeginPaymentPreAuth): void;
    abstract sendCallBeginPaymentPreAuthResolved(callBeginPaymentPreAuthResolved: ServerCallBeginPaymentPreAuthResolved): void;
    abstract sendServerFeeBreakdowns(feeBreakdowns: ServerFeeBreakdowns): void;
    abstract sendCounterpartyJoinedCall(counterpartyJoinedCall: ServerCounterpartyJoinedCall): void;
    abstract sendCounterpartyLeftCall(sendCounterpartyLeftCall: ServerCounterpartyLeftCall): void;
}
