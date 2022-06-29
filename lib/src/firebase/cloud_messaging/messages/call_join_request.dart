class CallJoinRequest {
  final String callerUid;
  final String calledUid;

  CallJoinRequest({required String callerUid, required String calledUid})
  : this.callerUid = callerUid, this.calledUid = calledUid {}
}
