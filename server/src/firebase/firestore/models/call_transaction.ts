export interface CallTransaction {
    callerUid: string;
    calledUid: string;
    callRequestTimeUtcMs: number;
    expertRateCentsPerMinute: number;
    expertRateCentsCallStart: number;
    agoraChannelName: string;
    callerCallStartPaymentStatusId: string;
}
