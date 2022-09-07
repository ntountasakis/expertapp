import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";
import {ExpertRate} from "../models/expert_rate";
import {CallJoinRequest} from "../../fcm/messages/call_join_request";
import {CallTransaction} from "../models/call_transaction";
import createStripePaymentIntent from "../../../stripe/payment_intent_creator";
import {PrivateUserInfo} from "../models/private_user_info";
import {PaymentStatus} from "../models/payment_status";
import {lookupUserFcmToken} from "./lookup_user_fcm_token";

type CallTransactionReturnType = [valid: boolean, errorMessage: string,
  callStartPaymentIntentClientSecret: string, callerStripeCustomerId: string,
  transaction: CallTransaction | undefined];

export const createCallTransaction = async ({request}: {request: CallJoinRequest}):
  Promise<CallTransactionReturnType> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    if (request.calledUid == null || request.calledUid == null) {
      const errorMessage = `Invalid Call Transaction Request, either ids are null.
      CalledUid: ${request.calledUid} CallerUid: ${request.callerUid}`;
      return callTransactionFailure(errorMessage);
    }
    const ratesCollectionRef = admin.firestore()
        .collection("expert_rates");
    const calledRateDoc = await transaction.get(
        ratesCollectionRef.doc(request.calledUid));

    if (!calledRateDoc.exists) {
      const errorMessage = `Called User: ${request.calledUid} does not have a registered rate`;
      return callTransactionFailure(errorMessage);
    }
    const privateUserInfoRef = admin.firestore()
        .collection("users");
    const privateCallerUserInfoDoc = await transaction.get(
        privateUserInfoRef.doc(request.callerUid));

    if (!privateCallerUserInfoDoc.exists) {
      const errorMessage = `Caller User: ${request.calledUid} does not have a private user info`;
      return callTransactionFailure(errorMessage);
    }

    const privateCallerUserInfo = privateCallerUserInfoDoc.data() as PrivateUserInfo;
    const callRate = calledRateDoc.data() as ExpertRate;

    const [tokenSuccess, tokenErrorMessage, calledUserFcmToken] = await lookupUserFcmToken(
        {userId: request.calledUid, transaction: transaction});

    if (!tokenSuccess) {
      return callTransactionFailure(tokenErrorMessage);
    }

    const callerCallStartPaymentStatusId = uuidv4();
    const [paymentIntentValid, paymentIntentErrorMessage, _, paymentIntentClientSecret] =
      await createStripePaymentIntent(privateCallerUserInfo.stripeCustomerId, privateCallerUserInfo.email,
          callRate.centsCallStart, "Begin Call Transaction", callerCallStartPaymentStatusId);

    if (!paymentIntentValid) {
      const errorMessage = `Cannot initiate payment start. ${paymentIntentErrorMessage}`;
      return callTransactionFailure(errorMessage);
    }

    console.log(`Found token ${calledUserFcmToken} for ${request.calledUid}`);

    const callRequestTimeUtcMs = Date.now();
    const transactionId = uuidv4();
    const agoraChannelName = uuidv4();

    const callerCallStartPaymentStatus: PaymentStatus = {
      "uid": request.callerUid,
      "status": "",
      "centsToCollect": callRate.centsCallStart,
      "centsCollected": 0,
    };

    const callStartPaymentDoc = admin.firestore()
        .collection("payment_statuses").doc(callerCallStartPaymentStatusId);

    transaction.create(callStartPaymentDoc, callerCallStartPaymentStatus);

    const newTransaction: CallTransaction = {
      "callTransactionId": transactionId,
      "callerUid": request.callerUid,
      "calledUid": request.calledUid,
      "calledFcmToken": calledUserFcmToken,
      "callRequestTimeUtcMs": callRequestTimeUtcMs,
      "expertRateCentsPerMinute": callRate.centsPerMinute,
      "expertRateCentsCallStart": callRate.centsCallStart,
      "agoraChannelName": agoraChannelName,
      "callerCallStartPaymentStatusId": callerCallStartPaymentStatusId,
    };

    const callTransactionDoc = admin.firestore()
        .collection("call_transactions").doc(transactionId);

    transaction.create(callTransactionDoc, newTransaction);

    return [true, "", paymentIntentClientSecret, privateCallerUserInfo.stripeCustomerId, newTransaction];
  });
};

function callTransactionFailure(errorMessage: string): CallTransactionReturnType {
  return [false, errorMessage, "", "", undefined];
}
