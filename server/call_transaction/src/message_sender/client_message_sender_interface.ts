import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallSummary} from "../protos/call_transaction_package/ServerCallSummary";
import {ServerCallJoinOrRequestResponse} from "../protos/call_transaction_package/ServerCallJoinOrRequestResponse";
import {ServerCallBeginPaymentPreAuth} from "../protos/call_transaction_package/ServerCallBeginPaymentPreAuth";
import {ServerCallBeginPaymentPreAuthResolved} from "../protos/call_transaction_package/ServerCallBeginPaymentPreAuthResolved";
import {ServerFeeBreakdowns} from "../protos/call_transaction_package/ServerFeeBreakdowns";
import {ServerBothPartiesReadyForCall} from "../protos/call_transaction_package/ServerBothPartiesReadyForCall";
import {ServerCounterpartyJoinedCall} from "../protos/call_transaction_package/ServerCounterpartyJoinedCall";
import {BaseCallState} from "../call_state/common/base_call_state";

export abstract class ClientMessageSenderInterface {
    abstract sendCallJoinOrRequestResponse(callJoinOrRequestResponse: ServerCallJoinOrRequestResponse, callState: BaseCallState): Promise<void>;
    abstract sendCallAgoraCredentials(callAgoraCredentials: ServerAgoraCredentials, callState: BaseCallState): Promise<void>;
    abstract sendCallBeginPaymentPreAuth(callBeginPaymentPreAuth: ServerCallBeginPaymentPreAuth, callState: BaseCallState): Promise<void>;
    abstract sendCallBeginPaymentPreAuthResolved(callBeginPaymentPreAuthResolved: ServerCallBeginPaymentPreAuthResolved,
        callState: BaseCallState): Promise<void>;
    abstract sendServerFeeBreakdowns(feeBreakdowns: ServerFeeBreakdowns, callState: BaseCallState): Promise<void>;
    abstract sendCounterpartyJoinedCall(counterpartyJoinedCall: ServerCounterpartyJoinedCall, callState: BaseCallState): Promise<void>;
    abstract sendCallSummary(callSummary: ServerCallSummary, callState: BaseCallState): Promise<void>;
    abstract sendServerBothPartiesReadyForCall(callReady: ServerBothPartiesReadyForCall, callState: BaseCallState): Promise<void>;
}
