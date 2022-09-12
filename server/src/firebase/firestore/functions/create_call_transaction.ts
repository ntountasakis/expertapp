import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";
import {CallJoinRequest} from "../../fcm/messages/call_join_request";
import {CallTransaction} from "../models/call_transaction";
import createStripePaymentIntent from "../../../stripe/payment_intent_creator";
import {PaymentStatus} from "../models/payment_status";
import {lookupUserFcmToken} from "./lookup_user_fcm_token";
import {getExpertRate, getPrivateUserInfo} from "./util/model_fetchers";
import {paymentIntentHelperFunc, PaymentIntentType} from "./util/payment_intent_helper";

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

    const [expertRateLookupErrorMessage, callRate] = await getExpertRate(request.calledUid, transaction);
    if (expertRateLookupErrorMessage !== "" || callRate === undefined) {
      return callTransactionFailure(expertRateLookupErrorMessage);
    }

    const [privateCallerInfoLookupErrorMessage, privateCallerUserInfo] = await getPrivateUserInfo(
        request.calledUid, transaction);
    if (privateCallerInfoLookupErrorMessage !== "" || privateCallerUserInfo === undefined) {
      return callTransactionFailure(privateCallerInfoLookupErrorMessage);
    }

    const [tokenSuccess, tokenLookupErrorMessage, calledUserFcmToken] = await lookupUserFcmToken(
        {userId: request.calledUid, transaction: transaction});

    if (!tokenSuccess) {
      return callTransactionFailure(tokenLookupErrorMessage);
    }

    const paymentIntentResult: PaymentIntentType = await paymentIntentHelperFunc(
        {costInCents: callRate.centsCallStart, privateUserInfo: privateCallerUserInfo,
          description: "Create Call Transaction"});

    if (typeof paymentIntentResult === "string") {
      return callTransactionFailure(paymentIntentResult);
    }
    const [paymentStatusId, paymentIntentClientSecret] = paymentIntentResult;

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

    const callStartPaymentDoc = admin.firestore().collection("payment_statuses").doc(paymentStatusId);

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
      "callerCallStartPaymentStatusId": paymentStatusId,
      "calledHasJoined": false,
      "calledJoinTimeUtcMs": 0,
      "callHasEnded": false,
      "callEndTimeUtsMs": 0,
    };

    const callTransactionDoc = admin.firestore()
        .collection("call_transactions").doc(transactionId);

    transaction.create(callTransactionDoc, newTransaction);

    return [true, "", paymentIntentClientSecret, privateCallerUserInfo.stripeCustomerId, newTransaction];
  });
};

function callTransactionFailure(errorMessage: string): CallTransactionReturnType {
  console.error(`Error in CreateCallTransaction: ${errorMessage}`);
  return [false, errorMessage, "", "", undefined];
}
