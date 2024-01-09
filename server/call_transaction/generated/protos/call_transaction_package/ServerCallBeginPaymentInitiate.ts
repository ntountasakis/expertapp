// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto


export interface ServerCallBeginPaymentInitiate {
  'clientSecret'?: (string);
  'customerId'?: (string);
  'ephemeralKey'?: (string);
}

export interface ServerCallBeginPaymentInitiate__Output {
  'clientSecret': (string);
  'customerId': (string);
  'ephemeralKey': (string);
}
