import {v4 as uuidv4} from "uuid";
import {getUtcMsSinceEpoch} from "../../../general/utils";
import {getCallTransactionDocumentRef} from "../document_fetchers/fetchers";
import {CallTransaction} from "../models/call_transaction";
import {ExpertRate} from "../models/expert_rate";
import {FcmToken} from "../models/fcm_token";

export function createCallTransactionDocument({transaction, callerUid, calledUid, calledUserFcmToken, expertRate, maxCallTimeSec}:
  {
    transaction: FirebaseFirestore.Transaction, callerUid: string, calledUid: string,
    calledUserFcmToken: FcmToken, expertRate: ExpertRate, maxCallTimeSec: number
  }): CallTransaction {
  const newTransaction: CallTransaction = {
    "callTransactionId": uuidv4(),
    "callerUid": callerUid,
    "calledUid": calledUid,
    "calledFcmToken": calledUserFcmToken.token,
    "callRequestTimeUtcMs": getUtcMsSinceEpoch(),
    "expertRateCentsPerMinute": expertRate.centsPerMinute,
    "expertRateCentsCallStart": expertRate.centsCallStart,
    "agoraChannelName": uuidv4(),
    "callerPaymentStatusId": uuidv4(),
    "callerTransferGroup": uuidv4(),
    "calledWasRung": false,
    "calledHasJoined": false,
    "calledJoinTimeUtcMs": 0,
    "callerFinishedTransaction": false,
    "calledFinishedTransaction": false,
    "callerNotifiedCalledJoined": false,
    "calledNotifiedCallerJoined": false,
    "callBeginTimeUtcMs": 0,
    "callEndTimeUtcMs": 0,
    "maxCallTimeSec": maxCallTimeSec,
    "lengthOfCallSec": 0,
    "costOfCallCents": 0,
    "platformFeeCents": 0,
    "earnedTotalCents": 0,
  };

  transaction.create(getCallTransactionDocumentRef({transactionId: newTransaction.callTransactionId}), newTransaction);

  return newTransaction;
}
