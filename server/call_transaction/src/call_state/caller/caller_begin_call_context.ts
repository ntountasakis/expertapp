import {ExpertRate} from "../../../../shared/src/firebase/firestore/models/expert_rate";

export class CallerBeginCallContext {
  transactionId: string;
  agoraChannelName: string;
  calledFcmToken: string;
  callerUid: string;
  calledUid: string;
  expertRate: ExpertRate;

  constructor({transactionId, agoraChannelName, callerUid, calledUid, expertRate, calledFcmToken}:
        {transactionId: string, agoraChannelName: string,
            calledFcmToken: string, callerUid: string,
          calledUid: string, expertRate: ExpertRate}) {
    this.transactionId = transactionId;
    this.agoraChannelName = agoraChannelName;
    this.calledFcmToken = calledFcmToken;
    this.callerUid = callerUid;
    this.calledUid = calledUid;
    this.expertRate = expertRate;
  }
}
