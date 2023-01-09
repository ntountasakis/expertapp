// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto

import type { ClientCallInitiateRequest as _call_transaction_package_ClientCallInitiateRequest, ClientCallInitiateRequest__Output as _call_transaction_package_ClientCallInitiateRequest__Output } from '../call_transaction_package/ClientCallInitiateRequest';
import type { ClientCallJoinRequest as _call_transaction_package_ClientCallJoinRequest, ClientCallJoinRequest__Output as _call_transaction_package_ClientCallJoinRequest__Output } from '../call_transaction_package/ClientCallJoinRequest';
import type { ClientCallDisconnectRequest as _call_transaction_package_ClientCallDisconnectRequest, ClientCallDisconnectRequest__Output as _call_transaction_package_ClientCallDisconnectRequest__Output } from '../call_transaction_package/ClientCallDisconnectRequest';

export interface ClientMessageContainer {
  'callInitiateRequest'?: (_call_transaction_package_ClientCallInitiateRequest | null);
  'callJoinRequest'?: (_call_transaction_package_ClientCallJoinRequest | null);
  'callDisconnectRequest'?: (_call_transaction_package_ClientCallDisconnectRequest | null);
  'messageWrapper'?: "callInitiateRequest"|"callJoinRequest"|"callDisconnectRequest";
}

export interface ClientMessageContainer__Output {
  'callInitiateRequest'?: (_call_transaction_package_ClientCallInitiateRequest__Output | null);
  'callJoinRequest'?: (_call_transaction_package_ClientCallJoinRequest__Output | null);
  'callDisconnectRequest'?: (_call_transaction_package_ClientCallDisconnectRequest__Output | null);
  'messageWrapper': "callInitiateRequest"|"callJoinRequest"|"callDisconnectRequest";
}
