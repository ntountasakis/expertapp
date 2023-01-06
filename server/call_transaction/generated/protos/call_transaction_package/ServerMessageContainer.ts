// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto

import type { ServerCallJoinOrRequestResponse as _call_transaction_package_ServerCallJoinOrRequestResponse, ServerCallJoinOrRequestResponse__Output as _call_transaction_package_ServerCallJoinOrRequestResponse__Output } from '../call_transaction_package/ServerCallJoinOrRequestResponse';
import type { ServerAgoraCredentials as _call_transaction_package_ServerAgoraCredentials, ServerAgoraCredentials__Output as _call_transaction_package_ServerAgoraCredentials__Output } from '../call_transaction_package/ServerAgoraCredentials';
import type { ServerCallBeginPaymentPreAuth as _call_transaction_package_ServerCallBeginPaymentPreAuth, ServerCallBeginPaymentPreAuth__Output as _call_transaction_package_ServerCallBeginPaymentPreAuth__Output } from '../call_transaction_package/ServerCallBeginPaymentPreAuth';
import type { ServerCallBeginPaymentPreAuthResolved as _call_transaction_package_ServerCallBeginPaymentPreAuthResolved, ServerCallBeginPaymentPreAuthResolved__Output as _call_transaction_package_ServerCallBeginPaymentPreAuthResolved__Output } from '../call_transaction_package/ServerCallBeginPaymentPreAuthResolved';
import type { ServerCounterpartyJoinedCall as _call_transaction_package_ServerCounterpartyJoinedCall, ServerCounterpartyJoinedCall__Output as _call_transaction_package_ServerCounterpartyJoinedCall__Output } from '../call_transaction_package/ServerCounterpartyJoinedCall';
import type { ServerFeeBreakdowns as _call_transaction_package_ServerFeeBreakdowns, ServerFeeBreakdowns__Output as _call_transaction_package_ServerFeeBreakdowns__Output } from '../call_transaction_package/ServerFeeBreakdowns';
import type { ServerCallSummary as _call_transaction_package_ServerCallSummary, ServerCallSummary__Output as _call_transaction_package_ServerCallSummary__Output } from '../call_transaction_package/ServerCallSummary';

export interface ServerMessageContainer {
  'serverCallJoinOrRequestResponse'?: (_call_transaction_package_ServerCallJoinOrRequestResponse | null);
  'serverAgoraCredentials'?: (_call_transaction_package_ServerAgoraCredentials | null);
  'serverCallBeginPaymentPreAuth'?: (_call_transaction_package_ServerCallBeginPaymentPreAuth | null);
  'serverCallBeginPaymentPreAuthResolved'?: (_call_transaction_package_ServerCallBeginPaymentPreAuthResolved | null);
  'serverCounterpartyJoinedCall'?: (_call_transaction_package_ServerCounterpartyJoinedCall | null);
  'serverFeeBreakdowns'?: (_call_transaction_package_ServerFeeBreakdowns | null);
  'serverCallSummary'?: (_call_transaction_package_ServerCallSummary | null);
  'messageWrapper'?: "serverCallJoinOrRequestResponse"|"serverAgoraCredentials"|"serverCallBeginPaymentPreAuth"|"serverCallBeginPaymentPreAuthResolved"|"serverCounterpartyJoinedCall"|"serverFeeBreakdowns"|"serverCallSummary";
}

export interface ServerMessageContainer__Output {
  'serverCallJoinOrRequestResponse'?: (_call_transaction_package_ServerCallJoinOrRequestResponse__Output | null);
  'serverAgoraCredentials'?: (_call_transaction_package_ServerAgoraCredentials__Output | null);
  'serverCallBeginPaymentPreAuth'?: (_call_transaction_package_ServerCallBeginPaymentPreAuth__Output | null);
  'serverCallBeginPaymentPreAuthResolved'?: (_call_transaction_package_ServerCallBeginPaymentPreAuthResolved__Output | null);
  'serverCounterpartyJoinedCall'?: (_call_transaction_package_ServerCounterpartyJoinedCall__Output | null);
  'serverFeeBreakdowns'?: (_call_transaction_package_ServerFeeBreakdowns__Output | null);
  'serverCallSummary'?: (_call_transaction_package_ServerCallSummary__Output | null);
  'messageWrapper': "serverCallJoinOrRequestResponse"|"serverAgoraCredentials"|"serverCallBeginPaymentPreAuth"|"serverCallBeginPaymentPreAuthResolved"|"serverCounterpartyJoinedCall"|"serverFeeBreakdowns"|"serverCallSummary";
}
