// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto

import type { Long } from '@grpc/proto-loader';

export interface ServerCallBeginPaymentPreAuthResolved {
  'joinCallTimeExpiryUtcMs'?: (number | string | Long);
}

export interface ServerCallBeginPaymentPreAuthResolved__Output {
  'joinCallTimeExpiryUtcMs': (string);
}
