import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";
import {getExpertRateDocument, getFcmTokenDocument, getUserMetadataDocument} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/firebase/firestore/models/call_transaction";
import {ExpertRate} from "../../../../../../../shared/firebase/firestore/models/expert_rate";
import {FcmToken} from "../../../../../../../shared/firebase/firestore/models/fcm_token";
import {PrivateUserInfo} from "../../../../../../../shared/firebase/firestore/models/private_user_info";
import {CallJoinRequest} from "../../../../fcm/messages/call_join_request";
import {paymentIntentHelperFunc, PaymentIntentType} from "../../util/payment_intent_helper";

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
    const expertRate: ExpertRate = await getExpertRateDocument({expertUid: request.calledUid});
    const privateCallerUserInfo: PrivateUserInfo = await getUserMetadataDocument({uid: request.callerUid});
    const calledUserFcmToken: FcmToken = await getFcmTokenDocument({uid: request.calledUid});

    const transferGroup = uuidv4();
    const paymentIntentResult: PaymentIntentType = await paymentIntentHelperFunc(
        {costInCents: expertRate.centsCallStart, privateUserInfo: privateCallerUserInfo,
          uid: request.calledUid, transferGroup: transferGroup, transaction: transaction,
          description: "Start Call"});

    if (typeof paymentIntentResult === "string") {
      return callTransactionFailure(paymentIntentResult);
    }
    const [paymentStatusId, paymentIntentClientSecret] = paymentIntentResult;

    console.log(`Found token ${calledUserFcmToken} for ${request.calledUid}`);

    const callRequestTimeUtcMs = Date.now();
    const transactionId = uuidv4();
    const agoraChannelName = uuidv4();

    const newTransaction: CallTransaction = {
      "callTransactionId": transactionId,
      "callerUid": request.callerUid,
      "calledUid": request.calledUid,
      "calledFcmToken": calledUserFcmToken.token,
      "callRequestTimeUtcMs": callRequestTimeUtcMs,
      "expertRateCentsPerMinute": expertRate.centsPerMinute,
      "expertRateCentsCallStart": expertRate.centsCallStart,
      "agoraChannelName": agoraChannelName,
      "callerCallStartPaymentStatusId": paymentStatusId,
      "callerCallTerminatePaymentStatusId": "",
      "callerTransferGroup": transferGroup,
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
