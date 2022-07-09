class CallJoinRequestTokenPayload {
  final String callerUid;
  final String calledUid;
  final String callTransactionId;

  CallJoinRequestTokenPayload(
      {required this.callerUid, required this.calledUid, required this.callTransactionId});
}
