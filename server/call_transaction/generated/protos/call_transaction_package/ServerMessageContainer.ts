// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto

import type { ServerCallJoinOrRequestResponse as _call_transaction_package_ServerCallJoinOrRequestResponse, ServerCallJoinOrRequestResponse__Output as _call_transaction_package_ServerCallJoinOrRequestResponse__Output } from '../call_transaction_package/ServerCallJoinOrRequestResponse';
import type { ServerAgoraCredentials as _call_transaction_package_ServerAgoraCredentials, ServerAgoraCredentials__Output as _call_transaction_package_ServerAgoraCredentials__Output } from '../call_transaction_package/ServerAgoraCredentials';
import type { ServerCallBeginPaymentInitiate as _call_transaction_package_ServerCallBeginPaymentInitiate, ServerCallBeginPaymentInitiate__Output as _call_transaction_package_ServerCallBeginPaymentInitiate__Output } from '../call_transaction_package/ServerCallBeginPaymentInitiate';
import type { ServerCallBeginPaymentInitiateResolved as _call_transaction_package_ServerCallBeginPaymentInitiateResolved, ServerCallBeginPaymentInitiateResolved__Output as _call_transaction_package_ServerCallBeginPaymentInitiateResolved__Output } from '../call_transaction_package/ServerCallBeginPaymentInitiateResolved';
import type { ServerCallTerminatePaymentInitiate as _call_transaction_package_ServerCallTerminatePaymentInitiate, ServerCallTerminatePaymentInitiate__Output as _call_transaction_package_ServerCallTerminatePaymentInitiate__Output } from '../call_transaction_package/ServerCallTerminatePaymentInitiate';
import type { ServerCallTerminatePaymentInitiateResolved as _call_transaction_package_ServerCallTerminatePaymentInitiateResolved, ServerCallTerminatePaymentInitiateResolved__Output as _call_transaction_package_ServerCallTerminatePaymentInitiateResolved__Output } from '../call_transaction_package/ServerCallTerminatePaymentInitiateResolved';
import type { ServerCounterpartyLeftCall as _call_transaction_package_ServerCounterpartyLeftCall, ServerCounterpartyLeftCall__Output as _call_transaction_package_ServerCounterpartyLeftCall__Output } from '../call_transaction_package/ServerCounterpartyLeftCall';
import type { ServerCounterpartyJoinedCall as _call_transaction_package_ServerCounterpartyJoinedCall, ServerCounterpartyJoinedCall__Output as _call_transaction_package_ServerCounterpartyJoinedCall__Output } from '../call_transaction_package/ServerCounterpartyJoinedCall';
import type { ServerFeeBreakdowns as _call_transaction_package_ServerFeeBreakdowns, ServerFeeBreakdowns__Output as _call_transaction_package_ServerFeeBreakdowns__Output } from '../call_transaction_package/ServerFeeBreakdowns';

export interface ServerMessageContainer {
  'serverCallJoinOrRequestResponse'?: (_call_transaction_package_ServerCallJoinOrRequestResponse | null);
  'serverAgoraCredentials'?: (_call_transaction_package_ServerAgoraCredentials | null);
  'serverCallBeginPaymentInitiate'?: (_call_transaction_package_ServerCallBeginPaymentInitiate | null);
  'serverCallBeginPaymentInitiateResolved'?: (_call_transaction_package_ServerCallBeginPaymentInitiateResolved | null);
  'serverCallTerminatePaymentInitiate'?: (_call_transaction_package_ServerCallTerminatePaymentInitiate | null);
  'serverCallTerminatePaymentInitiateResolved'?: (_call_transaction_package_ServerCallTerminatePaymentInitiateResolved | null);
  'serverCounterpartyLeftCall'?: (_call_transaction_package_ServerCounterpartyLeftCall | null);
  'serverCounterpartyJoinedCall'?: (_call_transaction_package_ServerCounterpartyJoinedCall | null);
  'serverFeeBreakdowns'?: (_call_transaction_package_ServerFeeBreakdowns | null);
  'messageWrapper'?: "serverCallJoinOrRequestResponse"|"serverAgoraCredentials"|"serverCallBeginPaymentInitiate"|"serverCallBeginPaymentInitiateResolved"|"serverCallTerminatePaymentInitiate"|"serverCallTerminatePaymentInitiateResolved"|"serverCounterpartyLeftCall"|"serverCounterpartyJoinedCall"|"serverFeeBreakdowns";
}

export interface ServerMessageContainer__Output {
  'serverCallJoinOrRequestResponse'?: (_call_transaction_package_ServerCallJoinOrRequestResponse__Output | null);
  'serverAgoraCredentials'?: (_call_transaction_package_ServerAgoraCredentials__Output | null);
  'serverCallBeginPaymentInitiate'?: (_call_transaction_package_ServerCallBeginPaymentInitiate__Output | null);
  'serverCallBeginPaymentInitiateResolved'?: (_call_transaction_package_ServerCallBeginPaymentInitiateResolved__Output | null);
  'serverCallTerminatePaymentInitiate'?: (_call_transaction_package_ServerCallTerminatePaymentInitiate__Output | null);
  'serverCallTerminatePaymentInitiateResolved'?: (_call_transaction_package_ServerCallTerminatePaymentInitiateResolved__Output | null);
  'serverCounterpartyLeftCall'?: (_call_transaction_package_ServerCounterpartyLeftCall__Output | null);
  'serverCounterpartyJoinedCall'?: (_call_transaction_package_ServerCounterpartyJoinedCall__Output | null);
  'serverFeeBreakdowns'?: (_call_transaction_package_ServerFeeBreakdowns__Output | null);
  'messageWrapper': "serverCallJoinOrRequestResponse"|"serverAgoraCredentials"|"serverCallBeginPaymentInitiate"|"serverCallBeginPaymentInitiateResolved"|"serverCallTerminatePaymentInitiate"|"serverCallTerminatePaymentInitiateResolved"|"serverCounterpartyLeftCall"|"serverCounterpartyJoinedCall"|"serverFeeBreakdowns";
}
