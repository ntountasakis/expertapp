export interface CallTransaction {
    callerUid: string;
    calledUid: string;
    callRequestTimeUtcMs: number;
    expertRateCentsPerMinute: number;
    agoraChannelName: string;
    callerCallInitiatePaymentIntentId: string;
}
