import {v4 as uuidv4} from "uuid";
import * as admin from "firebase-admin";
import {ExpertRate} from "../../../../../../../shared/src/firebase/firestore/models/expert_rate";
import {FcmToken} from "../../../../../../../shared/src/firebase/firestore/models/fcm_token";
import {CallJoinRequest} from "../../../../../../../shared/src/firebase/fcm/messages/call_join_request";
import {createCallTransactionDocument} from "../../../../../../../shared/src/firebase/firestore/functions/create_call_transaction_document";
import {getExpertRateDocument, getFcmTokenDocument, getPaymentStatusDocumentRef, getPrivateUserDocument, getUserOwedBalanceDocumentRef} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {PaymentStatus} from "../../../../../../../shared/src/firebase/firestore/models/payment_status";
import {PrivateUserInfo} from "../../../../../../../shared/src/firebase/firestore/models/private_user_info";
import createStripePaymentIntent from "../../../../../../../shared/src/stripe/payment_intent_creator";
import {createPaymentStatus} from "../../../../../../../shared/src/firebase/firestore/functions/create_payment_status";
import createCustomerEphemeralKey from "../../../../../../../shared/src/stripe/create_customer_ephemeral_key";
import callAllowedStripeConfigValid from "../../util/call_allowed_stripe_config_valid";
import {UserOwedBalance} from "../../../../../../../shared/src/firebase/firestore/models/user_owed_balance";

export const createCallTransaction = async ({request}: {request: CallJoinRequest}):
  Promise<[boolean, string, string, string, CallTransaction?]> => {
  const [canCreateCall, callTransaction, paymentStatus, userInfo] = await admin.firestore().runTransaction(async (transaction) => {
    if (request.calledUid == null || request.calledUid == null) {
      const errorMessage = `Invalid Call Transaction Request, either ids are null.
      CalledUid: ${request.calledUid} CallerUid: ${request.callerUid}`;
      throw new Error(errorMessage);
    }
    const expertRate: ExpertRate = await getExpertRateDocument(
        {transaction: transaction, expertUid: request.calledUid});
    const calledUserFcmToken: FcmToken = await getFcmTokenDocument({transaction: transaction, uid: request.calledUid});
    const callerUserInfo: PrivateUserInfo = await getPrivateUserDocument({transaction, uid: request.callerUid});
    const calledUserInfo: PrivateUserInfo = await getPrivateUserDocument({transaction, uid: request.calledUid});

    if (!callAllowedStripeConfigValid({callerUserInfo: callerUserInfo, calledUserInfo: calledUserInfo})) {
      return [false, null, null, null, null];
    }
    const balanceDoc = await getUserOwedBalanceDocumentRef({uid: request.callerUid}).get();
    if (balanceDoc.exists) {
      const owedBalance = balanceDoc.data() as UserOwedBalance;
      if (owedBalance.owedBalanceCents != 0) {
        console.error(`Caller: ${request.callerUid} has a balance of ${owedBalance.owedBalanceCents} cents. Disconnecting from call server`);
        return [false, null, null, null, null];
      }
    }

    const callTransaction: CallTransaction = createCallTransactionDocument({transaction: transaction, callerUid: request.callerUid,
      calledUid: request.calledUid, calledUserFcmToken: calledUserFcmToken, expertRate: expertRate});
    // starting call doesnt add to user balance, if they dont pay we just dont connect them
    const paymentStatus : PaymentStatus = await createPaymentStatus({transaction: transaction, uid: request.callerUid,
      transferGroup: callTransaction.callerTransferGroup, costInCents: callTransaction.expertRateCentsCallStart,
      paymentStatusId: callTransaction.callerCallStartPaymentStatusId, idempotencyKey: uuidv4()});
    return [true, callTransaction, paymentStatus, callerUserInfo];
  });

  if (canCreateCall && userInfo != null && callTransaction != null && paymentStatus != null) {
    const [paymentIntentId, paymentIntentClientSecret] = await createStripePaymentIntent({
      customerId: userInfo.stripeCustomerId,
      customerEmail: userInfo.email, amountToBillInCents: paymentStatus.centsToCollect,
      idempotencyKey: paymentStatus.idempotencyKey, transferGroup: paymentStatus.transferGroup, paymentStatusId: callTransaction.callerCallStartPaymentStatusId,
      paymentDescription: "Call Begin", uid: request.callerUid});
    await getPaymentStatusDocumentRef({paymentStatusId: callTransaction.callerCallStartPaymentStatusId}).update("paymentIntentId", paymentIntentId);

    const ephemeralKey = await createCustomerEphemeralKey({customerId: userInfo.stripeCustomerId});
    return [true, userInfo.stripeCustomerId, paymentIntentClientSecret, ephemeralKey, callTransaction];
  }
  return [false, "", "", ""];
};
