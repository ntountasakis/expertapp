export interface CallTransaction
{
    callTransactionId: string;
    callerUid: string;
    calledUid: string;
    calledFcmToken: string;
    callRequestTimeUtcMs: number;
    expertRateCentsPerMinute: number;
    expertRateCentsCallStart: number;
    agoraChannelName: string;
    callerCallStartPaymentStatusId: string;
    callerCallTerminatePaymentStatusId: string;
    calledHasJoined: boolean;
    calledJoinTimeUtcMs: number;
    callHasEnded: boolean;
    callEndTimeUtsMs: number;
}
