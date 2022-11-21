import {v4 as uuidv4} from "uuid";
import { getCallTransactionDocumentRef } from "../document_fetchers/fetchers";
import { CallTransaction } from "../models/call_transaction";
import { ExpertRate } from "../models/expert_rate";
import { FcmToken } from "../models/fcm_token";

export function createCallTransactionDocument({transaction, callerUid, calledUid, calledUserFcmToken, expertRate}:
{ transaction: FirebaseFirestore.Transaction, callerUid: string, calledUid: string,
calledUserFcmToken: FcmToken, expertRate: ExpertRate}): CallTransaction
{
    const newTransaction: CallTransaction = {
      "callTransactionId": uuidv4(),
      "callerUid": callerUid,
      "calledUid": calledUid,
      "calledFcmToken": calledUserFcmToken.token,
      "callRequestTimeUtcMs": Date.now(),
      "expertRateCentsPerMinute": expertRate.centsPerMinute,
      "expertRateCentsCallStart": expertRate.centsCallStart,
      "agoraChannelName": uuidv4(),
      "callerCallStartPaymentStatusId": uuidv4(),
      "callerCallTerminatePaymentStatusId": uuidv4(),
      "callerTransferGroup": uuidv4(),
      "calledHasJoined": false,
      "calledJoinTimeUtcMs": 0,
      "callHasEnded": false,
      "callEndTimeUtsMs": 0,
    };

    transaction.create(getCallTransactionDocumentRef({transactionId: newTransaction.callTransactionId}), newTransaction);

    return newTransaction;
}