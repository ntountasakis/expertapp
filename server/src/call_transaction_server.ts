import * as grpc from '@grpc/grpc-js';
import { CallMessage } from './protos/call_transaction_package/CallMessage';
import { CallRequest } from './protos/call_transaction_package/CallRequest';
import { CallTransactionHandlers } from './protos/call_transaction_package/CallTransaction';

const callTransactionServer: CallTransactionHandlers= {
    InitiateCall: function (call: grpc.ServerUnaryCall<CallRequest, CallMessage>, callback: grpc.sendUnaryData<CallMessage>): void {
        if (call.request) {
            console.log(`(server) Got client message: ${call.request.userAuthToken}`);
          }
          callback(null, {
            ack: 'Hello from the server',
          });
    }
};

export { callTransactionServer }