// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto

import type { ServerCallJoinOrRequestResponse as _call_transaction_package_ServerCallJoinOrRequestResponse, ServerCallJoinOrRequestResponse__Output as _call_transaction_package_ServerCallJoinOrRequestResponse__Output } from '../call_transaction_package/ServerCallJoinOrRequestResponse';
import type { ServerAgoraCredentials as _call_transaction_package_ServerAgoraCredentials, ServerAgoraCredentials__Output as _call_transaction_package_ServerAgoraCredentials__Output } from '../call_transaction_package/ServerAgoraCredentials';
import type { ServerCallBeginPaymentPreAuth as _call_transaction_package_ServerCallBeginPaymentPreAuth, ServerCallBeginPaymentPreAuth__Output as _call_transaction_package_ServerCallBeginPaymentPreAuth__Output } from '../call_transaction_package/ServerCallBeginPaymentPreAuth';
import type { ServerCallBeginPaymentPreAuthResolved as _call_transaction_package_ServerCallBeginPaymentPreAuthResolved, ServerCallBeginPaymentPreAuthResolved__Output as _call_transaction_package_ServerCallBeginPaymentPreAuthResolved__Output } from '../call_transaction_package/ServerCallBeginPaymentPreAuthResolved';
import type { ServerCounterpartyLeftCall as _call_transaction_package_ServerCounterpartyLeftCall, ServerCounterpartyLeftCall__Output as _call_transaction_package_ServerCounterpartyLeftCall__Output } from '../call_transaction_package/ServerCounterpartyLeftCall';
import type { ServerCounterpartyJoinedCall as _call_transaction_package_ServerCounterpartyJoinedCall, ServerCounterpartyJoinedCall__Output as _call_transaction_package_ServerCounterpartyJoinedCall__Output } from '../call_transaction_package/ServerCounterpartyJoinedCall';
import type { ServerFeeBreakdowns as _call_transaction_package_ServerFeeBreakdowns, ServerFeeBreakdowns__Output as _call_transaction_package_ServerFeeBreakdowns__Output } from '../call_transaction_package/ServerFeeBreakdowns';

export interface ServerMessageContainer {
  'serverCallJoinOrRequestResponse'?: (_call_transaction_package_ServerCallJoinOrRequestResponse | null);
  'serverAgoraCredentials'?: (_call_transaction_package_ServerAgoraCredentials | null);
  'serverCallBeginPaymentPreAuth'?: (_call_transaction_package_ServerCallBeginPaymentPreAuth | null);
  'serverCallBeginPaymentPreAuthResolved'?: (_call_transaction_package_ServerCallBeginPaymentPreAuthResolved | null);
  'serverCounterpartyLeftCall'?: (_call_transaction_package_ServerCounterpartyLeftCall | null);
  'serverCounterpartyJoinedCall'?: (_call_transaction_package_ServerCounterpartyJoinedCall | null);
  'serverFeeBreakdowns'?: (_call_transaction_package_ServerFeeBreakdowns | null);
  'messageWrapper'?: "serverCallJoinOrRequestResponse"|"serverAgoraCredentials"|"serverCallBeginPaymentPreAuth"|"serverCallBeginPaymentPreAuthResolved"|"serverCounterpartyLeftCall"|"serverCounterpartyJoinedCall"|"serverFeeBreakdowns";
}

export interface ServerMessageContainer__Output {
  'serverCallJoinOrRequestResponse'?: (_call_transaction_package_ServerCallJoinOrRequestResponse__Output | null);
  'serverAgoraCredentials'?: (_call_transaction_package_ServerAgoraCredentials__Output | null);
  'serverCallBeginPaymentPreAuth'?: (_call_transaction_package_ServerCallBeginPaymentPreAuth__Output | null);
  'serverCallBeginPaymentPreAuthResolved'?: (_call_transaction_package_ServerCallBeginPaymentPreAuthResolved__Output | null);
  'serverCounterpartyLeftCall'?: (_call_transaction_package_ServerCounterpartyLeftCall__Output | null);
  'serverCounterpartyJoinedCall'?: (_call_transaction_package_ServerCounterpartyJoinedCall__Output | null);
  'serverFeeBreakdowns'?: (_call_transaction_package_ServerFeeBreakdowns__Output | null);
  'messageWrapper': "serverCallJoinOrRequestResponse"|"serverAgoraCredentials"|"serverCallBeginPaymentPreAuth"|"serverCallBeginPaymentPreAuthResolved"|"serverCounterpartyLeftCall"|"serverCounterpartyJoinedCall"|"serverFeeBreakdowns";
}
