// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto


export interface ServerCallSummary {
  'lengthOfCallSec'?: (number);
  'costOfCallCents'?: (number);
  'paymentProcessorFeeCents'?: (number);
  'platformFeeCents'?: (number);
  'earnedTotalCents'?: (number);
}

export interface ServerCallSummary__Output {
  'lengthOfCallSec': (number);
  'costOfCallCents': (number);
  'paymentProcessorFeeCents': (number);
  'platformFeeCents': (number);
  'earnedTotalCents': (number);
}