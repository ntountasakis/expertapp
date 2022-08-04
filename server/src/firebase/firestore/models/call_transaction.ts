export interface CallTransaction {
    callerUid: string;
    calledUid: string;
    callRequestTimeUtcMs: number;
    expertRateDollarsPerMinute: number;
    agoraChannelName: string;
    callerCallInitiatePaymentIntentId: string;
}
