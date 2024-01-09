// Original file: /Users/ntountas/Code/expertapp/protos/call_transaction.proto

import type { Long } from '@grpc/proto-loader';

export interface ServerBothPartiesReadyForCall {
  'callStartUtcMs'?: (number | string | Long);
}

export interface ServerBothPartiesReadyForCall__Output {
  'callStartUtcMs': (string);
}
