export class CallJoinRequest {
  callerUid: string;
  calledUid: string;
  rateCentsStart: string;
  rateCentsPerMinute: string;

  constructor({ callerUid, calledUid, rateCentsStart, rateCentsPerMinute }:
    { callerUid: string, calledUid: string, rateCentsStart: string, rateCentsPerMinute: string }) {
    this.callerUid = callerUid;
    this.calledUid = calledUid;
    this.rateCentsStart = rateCentsStart;
    this.rateCentsPerMinute = rateCentsPerMinute;
  }

  static messageType(): string {
    return "call_join_request";
  }
}
