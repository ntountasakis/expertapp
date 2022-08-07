import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";
import {ExpertRate} from "./firebase/firestore/models/expert_rate";
import {CallTransctionRequestResult} from "./call_transaction_request_result";
import {lookupUserFcmToken} from "./firebase/firestore/lookup_user_fcm_token";
import {CallJoinRequest} from "./firebase/fcm/messages/call_join_request";
import {CallTransaction} from "./firebase/firestore/models/call_transaction";
import createStripePaymentIntent from "./stripe/payment_intent_creator";
import {PrivateUserInfo} from "./firebase/firestore/models/private_user_info";

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
      myResult.errorMessage = `Called User: ${request.calledUid} does not have a registered rate`;
      return;
    }
    const privateUserInfoRef = admin.firestore()
        .collection("users");
    const privateCallerUserInfoDoc = await transaction.get(
        privateUserInfoRef.doc(request.callerUid));

    if (!privateCallerUserInfoDoc.exists) {
      myResult.errorMessage = `Caller User: ${request.calledUid} does not have a private user info`;
      return;
    }

    const privateCallerUserInfo = privateCallerUserInfoDoc.data() as PrivateUserInfo;
    const callRate = calledRateDoc.data() as ExpertRate;

    const [tokenSuccess, tokenErrorMessage, calledUserFcmToken] = await lookupUserFcmToken(
        {userId: request.calledUid, transaction: transaction});

    if (!tokenSuccess) {
      myResult.errorMessage = tokenErrorMessage;
      return;
    }


    const [paymentIntentValid, paymentIntentErrorMessage, paymentIntentId, paymentIntentClientSecret] =
      await createStripePaymentIntent(privateCallerUserInfo.stripeCustomerId, privateCallerUserInfo.email,
          callRate.centsPerMinute, "Call Transaction");

    if (!paymentIntentValid) {
      myResult.errorMessage = `Cannot initiate payment start. ${paymentIntentErrorMessage}`;
      return;
    }


    console.log(`Found token ${calledUserFcmToken} for ${request.calledUid}`);

    const callRequestTimeUtcMs = Date.now();
    const transactionId = uuidv4();
    const agoraChannelName = uuidv4();

    const newTransaction: CallTransaction = {
      "callerUid": request.callerUid,
      "calledUid": request.calledUid,
      "callRequestTimeUtcMs": callRequestTimeUtcMs,
      "expertRateCentsPerMinute": callRate.centsPerMinute,
      "agoraChannelName": agoraChannelName,
      "callerCallInitiatePaymentIntentId": paymentIntentId,
    };

    const callTransactionDoc = admin.firestore()
        .collection("call_transactions").doc(transactionId);

    transaction.create(callTransactionDoc, newTransaction);
    myResult.success = true;
    myResult.calledFcmToken = calledUserFcmToken;
    myResult.callTransactionId = transactionId;
    myResult.agoraChannelName = agoraChannelName;
    myResult.stripeCallerClientSecret = paymentIntentClientSecret;
    myResult.stripeCallerCustomerId = privateCallerUserInfo.stripeCustomerId;
  });
  return myResult;
};
