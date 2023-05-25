// Original file: /Users/ntountas/Code/expertapp/protos/call_transaction.proto

import type { ClientCallInitiateRequest as _call_transaction_package_ClientCallInitiateRequest, ClientCallInitiateRequest__Output as _call_transaction_package_ClientCallInitiateRequest__Output } from '../call_transaction_package/ClientCallInitiateRequest';
import type { ClientCallJoinRequest as _call_transaction_package_ClientCallJoinRequest, ClientCallJoinRequest__Output as _call_transaction_package_ClientCallJoinRequest__Output } from '../call_transaction_package/ClientCallJoinRequest';
import type { ClientCallDisconnectRequest as _call_transaction_package_ClientCallDisconnectRequest, ClientCallDisconnectRequest__Output as _call_transaction_package_ClientCallDisconnectRequest__Output } from '../call_transaction_package/ClientCallDisconnectRequest';
import type { ClientNotifyRemoteJoinedCall as _call_transaction_package_ClientNotifyRemoteJoinedCall, ClientNotifyRemoteJoinedCall__Output as _call_transaction_package_ClientNotifyRemoteJoinedCall__Output } from '../call_transaction_package/ClientNotifyRemoteJoinedCall';
import type { ClientKeepAlivePing as _call_transaction_package_ClientKeepAlivePing, ClientKeepAlivePing__Output as _call_transaction_package_ClientKeepAlivePing__Output } from '../call_transaction_package/ClientKeepAlivePing';

export interface ClientMessageContainer {
  'callInitiateRequest'?: (_call_transaction_package_ClientCallInitiateRequest | null);
  'callJoinRequest'?: (_call_transaction_package_ClientCallJoinRequest | null);
  'callDisconnectRequest'?: (_call_transaction_package_ClientCallDisconnectRequest | null);
  'notifyRemoteJoinedCall'?: (_call_transaction_package_ClientNotifyRemoteJoinedCall | null);
  'keepAlivePing'?: (_call_transaction_package_ClientKeepAlivePing | null);
  'messageWrapper'?: "callInitiateRequest"|"callJoinRequest"|"callDisconnectRequest"|"notifyRemoteJoinedCall"|"keepAlivePing";
}

export interface ClientMessageContainer__Output {
  'callInitiateRequest'?: (_call_transaction_package_ClientCallInitiateRequest__Output | null);
  'callJoinRequest'?: (_call_transaction_package_ClientCallJoinRequest__Output | null);
  'callDisconnectRequest'?: (_call_transaction_package_ClientCallDisconnectRequest__Output | null);
  'notifyRemoteJoinedCall'?: (_call_transaction_package_ClientNotifyRemoteJoinedCall__Output | null);
  'keepAlivePing'?: (_call_transaction_package_ClientKeepAlivePing__Output | null);
  'messageWrapper': "callInitiateRequest"|"callJoinRequest"|"callDisconnectRequest"|"notifyRemoteJoinedCall"|"keepAlivePing";
}
