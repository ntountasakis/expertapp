// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto


export interface ServerFeeBreakdowns {
  'platformPercentFee'?: (number | string);
  'earnedCentsStartCall'?: (number);
  'earnedCentsPerMinute'?: (number);
}

export interface ServerFeeBreakdowns__Output {
  'platformPercentFee': (number);
  'earnedCentsStartCall': (number);
  'earnedCentsPerMinute': (number);
}
