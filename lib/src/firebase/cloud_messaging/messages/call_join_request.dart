class CallJoinRequestTokenPayload {
  final String callerUid;
  final String calledUid;
  final String callTransactionId;
  final String callRateStartCents;
  final String callRatePerMinuteCents;
  final String callJoinExpirationTimeUtcMs;

  CallJoinRequestTokenPayload(
      {required this.callerUid, required this.calledUid,
      required this.callTransactionId, required this.callRateStartCents,
      required this.callRatePerMinuteCents,
      required this.callJoinExpirationTimeUtcMs});
}
