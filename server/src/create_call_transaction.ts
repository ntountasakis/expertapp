import {CallRequest} from "./protos/call_transaction_package/CallRequest";
import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";
import {ExpertRate} from "./firebase/firestore/models/expert_rate";

export const createCallTransaction = async (request: CallRequest): Promise<boolean> => {
  const success = await admin.firestore().runTransaction(async (transaction) => {
    if (request.calledUid == null || request.calledUid == null) {
      console.error(`Invalid Call Transaction Request, either ids are null. 
      CalledUid: ${request.calledUid} CallerUid: ${request.callerUid}`);
      return false;
    }
    const ratesCollectionRef = admin.firestore()
        .collection("expert_rates");
    const calledRateDoc = await transaction.get(
        ratesCollectionRef.doc(request.calledUid));

    if (!calledRateDoc.exists) {
      console.error("Called User does not have a registered rate");
      return false;
    }

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

    console.log("Transaction complete");
    return true;
  });

  return success;
};
