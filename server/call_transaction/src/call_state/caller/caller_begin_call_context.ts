import {CallJoinRequest} from "../../../../shared/src/firebase/fcm/messages/call_join_request";

export class CallerBeginCallContext {
  transactionId: string;
  agoraChannelName: string;
  calledFcmToken: string;
  callJoinRequest: CallJoinRequest;

  constructor({transactionId, agoraChannelName, callJoinRequest, calledFcmToken}:
        {transactionId: string, agoraChannelName: string,
            calledFcmToken: string, callJoinRequest: CallJoinRequest}) {
    this.transactionId = transactionId;
    this.agoraChannelName = agoraChannelName;
    this.calledFcmToken = calledFcmToken;
    this.callJoinRequest = callJoinRequest;
  }
}
