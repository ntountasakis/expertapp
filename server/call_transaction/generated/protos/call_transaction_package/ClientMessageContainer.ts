// Original file: /Users/ntountas/Code/expertapp/protos/call_transaction.proto

import type { ClientCallInitiateRequest as _call_transaction_package_ClientCallInitiateRequest, ClientCallInitiateRequest__Output as _call_transaction_package_ClientCallInitiateRequest__Output } from '../call_transaction_package/ClientCallInitiateRequest';
import type { ClientCallJoinRequest as _call_transaction_package_ClientCallJoinRequest, ClientCallJoinRequest__Output as _call_transaction_package_ClientCallJoinRequest__Output } from '../call_transaction_package/ClientCallJoinRequest';
import type { ClientCallTerminateRequest as _call_transaction_package_ClientCallTerminateRequest, ClientCallTerminateRequest__Output as _call_transaction_package_ClientCallTerminateRequest__Output } from '../call_transaction_package/ClientCallTerminateRequest';

export interface ClientMessageContainer {
  'callInitiateRequest'?: (_call_transaction_package_ClientCallInitiateRequest | null);
  'callJoinRequest'?: (_call_transaction_package_ClientCallJoinRequest | null);
  'callTerminateRequest'?: (_call_transaction_package_ClientCallTerminateRequest | null);
  'messageWrapper'?: "callInitiateRequest"|"callJoinRequest"|"callTerminateRequest";
}

export interface ClientMessageContainer__Output {
  'callInitiateRequest'?: (_call_transaction_package_ClientCallInitiateRequest__Output | null);
  'callJoinRequest'?: (_call_transaction_package_ClientCallJoinRequest__Output | null);
  'callTerminateRequest'?: (_call_transaction_package_ClientCallTerminateRequest__Output | null);
  'messageWrapper': "callInitiateRequest"|"callJoinRequest"|"callTerminateRequest";
}
