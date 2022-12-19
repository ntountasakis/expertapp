// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto


export interface ServerCallBeginPaymentPreAuth {
  'clientSecret'?: (string);
  'customerId'?: (string);
  'ephemeralKey'?: (string);
}

export interface ServerCallBeginPaymentPreAuth__Output {
  'clientSecret': (string);
  'customerId': (string);
  'ephemeralKey': (string);
}
