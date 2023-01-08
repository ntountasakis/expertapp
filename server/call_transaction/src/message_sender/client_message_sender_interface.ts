import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallSummary} from "../protos/call_transaction_package/ServerCallSummary";
import {ServerCallJoinOrRequestResponse} from "../protos/call_transaction_package/ServerCallJoinOrRequestResponse";
import {ServerCallBeginPaymentPreAuth} from "../protos/call_transaction_package/ServerCallBeginPaymentPreAuth";
import {ServerCallBeginPaymentPreAuthResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentPreAuthResolved";
import {ServerFeeBreakdowns} from "../protos/call_transaction_package/ServerFeeBreakdowns";
import {ServerCounterpartyJoinedCall} from "../protos/call_transaction_package/ServerCounterpartyJoinedCall";

export abstract class ClientMessageSenderInterface {
    abstract sendCallJoinOrRequestResponse(callJoinOrRequestResponse: ServerCallJoinOrRequestResponse): Promise<void>;
    abstract sendCallAgoraCredentials(callAgoraCredentials: ServerAgoraCredentials): Promise<void>;
    abstract sendCallBeginPaymentPreAuth(callBeginPaymentPreAuth: ServerCallBeginPaymentPreAuth): Promise<void>;
    abstract sendCallBeginPaymentPreAuthResolved(callBeginPaymentPreAuthResolved: ServerCallBeginPaymentPreAuthResolved): Promise<void>;
    abstract sendServerFeeBreakdowns(feeBreakdowns: ServerFeeBreakdowns): Promise<void>;
    abstract sendCounterpartyJoinedCall(counterpartyJoinedCall: ServerCounterpartyJoinedCall): Promise<void>;
    abstract sendCallSummary(callSummary: ServerCallSummary): Promise<void>;
}
