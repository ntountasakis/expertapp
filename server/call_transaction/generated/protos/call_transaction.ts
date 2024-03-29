import type * as grpc from '@grpc/grpc-js';
import type { MessageTypeDefinition } from '@grpc/proto-loader';

import type { CallTransactionClient as _call_transaction_package_CallTransactionClient, CallTransactionDefinition as _call_transaction_package_CallTransactionDefinition } from './call_transaction_package/CallTransaction';

type SubtypeConstructor<Constructor extends new (...args: any) => any, Subtype> = {
  new(...args: ConstructorParameters<Constructor>): Subtype;
};

export interface ProtoGrpcType {
  call_transaction_package: {
    CallTransaction: SubtypeConstructor<typeof grpc.Client, _call_transaction_package_CallTransactionClient> & { service: _call_transaction_package_CallTransactionDefinition }
    ClientCallDisconnectRequest: MessageTypeDefinition
    ClientCallInitiateRequest: MessageTypeDefinition
    ClientCallJoinRequest: MessageTypeDefinition
    ClientKeepAlivePing: MessageTypeDefinition
    ClientMessageContainer: MessageTypeDefinition
    ClientNotifyRemoteJoinedCall: MessageTypeDefinition
    ServerAgoraCredentials: MessageTypeDefinition
    ServerBothPartiesReadyForCall: MessageTypeDefinition
    ServerCallBeginPaymentPreAuth: MessageTypeDefinition
    ServerCallBeginPaymentPreAuthResolved: MessageTypeDefinition
    ServerCallJoinOrRequestResponse: MessageTypeDefinition
    ServerCallSummary: MessageTypeDefinition
    ServerCounterpartyJoinedCall: MessageTypeDefinition
    ServerFeeBreakdowns: MessageTypeDefinition
    ServerKeepAlivePong: MessageTypeDefinition
    ServerMessageContainer: MessageTypeDefinition
  }
}

