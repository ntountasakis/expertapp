import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";
import {ExpertRate} from "./firebase/firestore/models/expert_rate";
import {CallTransctionRequestResult} from "./call_transaction_request_result";
import {lookupUserToken} from "./firebase/firestore/lookup_user_token";
import {CallJoinRequest} from "./firebase/fcm/messages/call_join_request";

export const createCallTransaction = async ({request}: {request: CallJoinRequest}):
Promise<CallTransctionRequestResult> => {
  const myResult = new CallTransctionRequestResult();
  await admin.firestore().runTransaction(async (transaction) => {
    if (request.calledUid == null || request.calledUid == null) {
      myResult.errorMessage = `Invalid Call Transaction Request, either ids are null. 
      CalledUid: ${request.calledUid} CallerUid: ${request.callerUid}`;
      return;
    }
    const ratesCollectionRef = admin.firestore()
        .collection("expert_rates");
    const calledRateDoc = await transaction.get(
        ratesCollectionRef.doc(request.calledUid));

    if (!calledRateDoc.exists) {
      myResult.errorMessage = `Called User: ${request.calledUid} 
      does not have a registered rate`;
      return;
    }

    const [tokenSuccess, tokenErrorMessage, calledUserToken] = await lookupUserToken(
        {userId: request.calledUid, transaction: transaction});

    if (!tokenSuccess) {
      myResult.errorMessage = tokenErrorMessage;
      return;
    }

    console.log(`Found token ${calledUserToken} for ${request.calledUid}`);

    myResult.calledToken = calledUserToken;

    const callRate = calledRateDoc.data() as ExpertRate;
    const callRequestTimeUtcMs = Date.now();
    const transactionId = uuidv4();

    const newTransaction = {
      "callerUid": request.callerUid,
      "calledUid": request.calledUid,
      "callRequestTimeUtcMs": callRequestTimeUtcMs,
      "expertRateDollarsPerMinute": callRate.dollarsPerMinute,
    };

    const callTransactionDoc = admin.firestore()
        .collection("call_transactions").doc(transactionId);

    transaction.create(callTransactionDoc, newTransaction);
    myResult.success = true;
    myResult.callTransactionId = transactionId;
  });
  return myResult;
};
