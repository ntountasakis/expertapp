export class CallJoinRequest {
    callerUid: string;
    calledUid: string;

    constructor({callerUid, calledUid}: {callerUid: string, calledUid: string}) {
      this.callerUid = callerUid;
      this.calledUid = calledUid;
    }

    messageType(): string {
      return "call_join_request";
    }
}
