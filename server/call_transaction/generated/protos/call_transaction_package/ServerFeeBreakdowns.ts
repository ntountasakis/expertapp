// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto


export interface ServerFeeBreakdowns {
  'paymentProcessorPercentFee'?: (number | string);
  'paymentProcessorCentsFlatFee'?: (number);
  'platformPercentFee'?: (number | string);
  'earnedCentsStartCall'?: (number);
  'earnedCentsPerMinute'?: (number);
}

export interface ServerFeeBreakdowns__Output {
  'paymentProcessorPercentFee': (number);
  'paymentProcessorCentsFlatFee': (number);
  'platformPercentFee': (number);
  'earnedCentsStartCall': (number);
  'earnedCentsPerMinute': (number);
}
