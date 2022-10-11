import { getCallTransactionDocumentRef } from "../document_fetchers/fetchers";
import { CallTransaction } from "../models/call_transaction";
import { ExpertRate } from "../models/expert_rate";
import { FcmToken } from "../models/fcm_token";

export function createCallTransactionDocument({transaction, transactionId, callerUid, calledUid,
calledUserFcmToken, expertRate, transferGroup, callRequestTimeUtcMs, agoraChannelName,
paymentStatusId}:
{ transaction: FirebaseFirestore.Transaction,
transactionId: string, callerUid: string, calledUid: string,
calledUserFcmToken: FcmToken, expertRate: ExpertRate, transferGroup: string, 
callRequestTimeUtcMs: number, agoraChannelName: string,
paymentStatusId: string}): CallTransaction
{
    const newTransaction: CallTransaction = {
      "callTransactionId": transactionId,
      "callerUid": callerUid,
      "calledUid": calledUid,
      "calledFcmToken": calledUserFcmToken.token,
      "callRequestTimeUtcMs": callRequestTimeUtcMs,
      "expertRateCentsPerMinute": expertRate.centsPerMinute,
      "expertRateCentsCallStart": expertRate.centsCallStart,
      "callerFinalCostCallTerminate": 0,
      "agoraChannelName": agoraChannelName,
      "callerCallStartPaymentStatusId": paymentStatusId,
      "callerCallTerminatePaymentStatusId": "",
      "callerTransferGroup": transferGroup,
      "calledHasJoined": false,
      "calledJoinTimeUtcMs": 0,
      "callHasEnded": false,
      "callEndTimeUtsMs": 0,
    };

    transaction.create(getCallTransactionDocumentRef({transactionId: transactionId}), newTransaction);

    return newTransaction;
}