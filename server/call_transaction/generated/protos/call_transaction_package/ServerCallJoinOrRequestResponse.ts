// Original file: /home/ntountas/Code/expertapp/protos/call_transaction.proto


export interface ServerCallJoinOrRequestResponse {
  'success'?: (boolean);
  'errorMessage'?: (string);
  'callTransactionId'?: (string);
  'secondsCallAuthorizedFor'?: (number);
}

export interface ServerCallJoinOrRequestResponse__Output {
  'success': (boolean);
  'errorMessage': (string);
  'callTransactionId': (string);
  'secondsCallAuthorizedFor': (number);
}
