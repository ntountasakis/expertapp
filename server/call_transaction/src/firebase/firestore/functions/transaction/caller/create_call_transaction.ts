import {v4 as uuidv4} from "uuid";
import * as admin from "firebase-admin";
import {ExpertRate} from "../../../../../../../shared/src/firebase/firestore/models/expert_rate";
import {FcmToken} from "../../../../../../../shared/src/firebase/firestore/models/fcm_token";
import {CallJoinRequest} from "../../../../../../../shared/src/firebase/fcm/messages/call_join_request";
import {createCallTransactionDocument} from "../../../../../../../shared/src/firebase/firestore/functions/create_call_transaction_document";
import {getExpertRateDocument, getFcmTokenDocument, getPaymentStatusDocumentRef, getPrivateUserDocument} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {PaymentStatus} from "../../../../../../../shared/src/firebase/firestore/models/payment_status";
import {PrivateUserInfo} from "../../../../../../../shared/src/firebase/firestore/models/private_user_info";
import createStripePaymentIntent from "../../../../../../../shared/src/stripe/payment_intent_creator";
import {createPaymentStatus} from "../../../../../../../shared/src/firebase/firestore/functions/create_payment_status";

export const createCallTransaction = async ({request}: {request: CallJoinRequest}):
  Promise<[CallTransaction, string, string]> => {
  const [callTransaction, paymentStatus, userInfo] = await admin.firestore().runTransaction(async (transaction) => {
    if (request.calledUid == null || request.calledUid == null) {
      const errorMessage = `Invalid Call Transaction Request, either ids are null.
      CalledUid: ${request.calledUid} CallerUid: ${request.callerUid}`;
      throw new Error(errorMessage);
    }
    const expertRate: ExpertRate = await getExpertRateDocument(
        {transaction: transaction, expertUid: request.calledUid});
    const calledUserFcmToken: FcmToken = await getFcmTokenDocument({transaction: transaction, uid: request.calledUid});
    const userInfo: PrivateUserInfo = await getPrivateUserDocument({transaction, uid: request.callerUid});

    const callTransaction: CallTransaction = createCallTransactionDocument({transaction: transaction, callerUid: request.callerUid,
      calledUid: request.calledUid, calledUserFcmToken: calledUserFcmToken, expertRate: expertRate});
    // starting call doesnt add to user balance, if they dont pay we just dont connect them
    const paymentStatus : PaymentStatus = await createPaymentStatus({transaction: transaction, uid: request.callerUid,
      transferGroup: callTransaction.callerTransferGroup, costInCents: callTransaction.expertRateCentsCallStart,
      paymentStatusId: callTransaction.callerCallStartPaymentStatusId, idempotencyKey: uuidv4()});
    return [callTransaction, paymentStatus, userInfo];
  });

  const [paymentIntentId, paymentIntentClientSecret] = await createStripePaymentIntent({
    customerId: userInfo.stripeCustomerId,
    customerEmail: userInfo.email, amountToBillInCents: paymentStatus.centsToCollect,
    idempotencyKey: paymentStatus.idempotencyKey, transferGroup: paymentStatus.transferGroup, paymentStatusId: callTransaction.callerCallStartPaymentStatusId,
    paymentDescription: "Call Begin", uid: request.callerUid});
  await getPaymentStatusDocumentRef({paymentStatusId: callTransaction.callerCallStartPaymentStatusId}).update("paymentIntentId", paymentIntentId);

  return [callTransaction, userInfo.stripeCustomerId, paymentIntentClientSecret];
};
