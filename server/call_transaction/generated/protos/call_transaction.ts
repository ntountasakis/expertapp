import type * as grpc from '@grpc/grpc-js';
import type { MessageTypeDefinition } from '@grpc/proto-loader';

import type { CallTransactionClient as _call_transaction_package_CallTransactionClient, CallTransactionDefinition as _call_transaction_package_CallTransactionDefinition } from './call_transaction_package/CallTransaction';

type SubtypeConstructor<Constructor extends new (...args: any) => any, Subtype> = {
  new(...args: ConstructorParameters<Constructor>): Subtype;
};

export interface ProtoGrpcType {
  call_transaction_package: {
    CallTransaction: SubtypeConstructor<typeof grpc.Client, _call_transaction_package_CallTransactionClient> & { service: _call_transaction_package_CallTransactionDefinition }
    ClientCallInitiateRequest: MessageTypeDefinition
    ClientCallJoinRequest: MessageTypeDefinition
    ClientMessageContainer: MessageTypeDefinition
    ServerAgoraCredentials: MessageTypeDefinition
    ServerCallBeginPaymentPreAuth: MessageTypeDefinition
    ServerCallBeginPaymentPreAuthResolved: MessageTypeDefinition
    ServerCallJoinOrRequestResponse: MessageTypeDefinition
    ServerCounterpartyJoinedCall: MessageTypeDefinition
    ServerFeeBreakdowns: MessageTypeDefinition
    ServerMessageContainer: MessageTypeDefinition
  }
}

