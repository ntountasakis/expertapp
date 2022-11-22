// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto

import type * as grpc from '@grpc/grpc-js'
import type { MethodDefinition } from '@grpc/proto-loader'
import type { ClientMessageContainer as _call_transaction_package_ClientMessageContainer, ClientMessageContainer__Output as _call_transaction_package_ClientMessageContainer__Output } from '../call_transaction_package/ClientMessageContainer';
import type { ServerMessageContainer as _call_transaction_package_ServerMessageContainer, ServerMessageContainer__Output as _call_transaction_package_ServerMessageContainer__Output } from '../call_transaction_package/ServerMessageContainer';

export interface CallTransactionClient extends grpc.Client {
  InitiateCall(metadata: grpc.Metadata, options?: grpc.CallOptions): grpc.ClientDuplexStream<_call_transaction_package_ClientMessageContainer, _call_transaction_package_ServerMessageContainer__Output>;
  InitiateCall(options?: grpc.CallOptions): grpc.ClientDuplexStream<_call_transaction_package_ClientMessageContainer, _call_transaction_package_ServerMessageContainer__Output>;
  initiateCall(metadata: grpc.Metadata, options?: grpc.CallOptions): grpc.ClientDuplexStream<_call_transaction_package_ClientMessageContainer, _call_transaction_package_ServerMessageContainer__Output>;
  initiateCall(options?: grpc.CallOptions): grpc.ClientDuplexStream<_call_transaction_package_ClientMessageContainer, _call_transaction_package_ServerMessageContainer__Output>;
  
}

export interface CallTransactionHandlers extends grpc.UntypedServiceImplementation {
  InitiateCall: grpc.handleBidiStreamingCall<_call_transaction_package_ClientMessageContainer__Output, _call_transaction_package_ServerMessageContainer>;
  
}

export interface CallTransactionDefinition extends grpc.ServiceDefinition {
  InitiateCall: MethodDefinition<_call_transaction_package_ClientMessageContainer, _call_transaction_package_ServerMessageContainer, _call_transaction_package_ClientMessageContainer__Output, _call_transaction_package_ServerMessageContainer__Output>
}
