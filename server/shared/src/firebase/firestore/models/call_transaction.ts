export interface CallTransaction {
    callTransactionId: string;
    callerUid: string;
    calledUid: string;
    calledFcmToken: string;
    callRequestTimeUtcMs: number;
    expertRateCentsPerMinute: number;
    expertRateCentsCallStart: number;
    agoraChannelName: string;
    callerPaymentStatusId: string;
    callerTransferGroup: string;
    calledWasRung: boolean;
    calledHasJoined: boolean;
    calledJoinTimeUtcMs: number;
    callerFinishedTransaction: boolean;
    calledFinishedTransaction: boolean;
    callEndTimeUtsMs: number;
    maxCallTimeSec: number;
    lengthOfCallSec: number;
    costOfCallCents: number;
    paymentProcessorFeeCents: number;
    platformFeeCents: number;
    earnedTotalCents: number;
}