import {v4 as uuidv4} from "uuid";
import * as admin from "firebase-admin";
import {ExpertRate} from "../../../../../../../shared/src/firebase/firestore/models/expert_rate";
import {FcmToken} from "../../../../../../../shared/src/firebase/firestore/models/fcm_token";
import {createCallTransactionDocument} from "../../../../../../../shared/src/firebase/firestore/functions/create_call_transaction_document";
import {getExpertRateDocument, getFcmTokenDocument, getPaymentStatusDocumentRef, getPrivateUserDocument, getUserOwedBalanceDocumentRef} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {PrivateUserInfo} from "../../../../../../../shared/src/firebase/firestore/models/private_user_info";
import {createStripePaymentIntentPreAuth} from "../../../../../../../shared/src/stripe/payment_intent_creator";
import {createPaymentStatus} from "../../../../../../../shared/src/firebase/firestore/functions/create_payment_status";
import createCustomerEphemeralKey from "../../../../../../../shared/src/stripe/create_customer_ephemeral_key";
import callAllowedStripeConfigValid from "../../util/call_allowed_stripe_config_valid";
import {UserOwedBalance} from "../../../../../../../shared/src/firebase/firestore/models/user_owed_balance";
import {PaymentContext} from "../../../../../../../shared/src/firebase/firestore/models/payment_status";
import {calculateMaxCallLengthSec} from "../../util/call_cost_calculator";

export const createCallTransaction = async ({callerUid, calledUid}: {callerUid: string, calledUid: string}):
  Promise<[boolean, string, string, string, CallTransaction?, ExpertRate?]> => {
  const amountCentsPreAuth = 300;
  const [canCreateCall, callTransaction, paymentStatus, userInfo, expertRate] = await admin.firestore().runTransaction(async (transaction) => {
    if (calledUid == null || calledUid == null) {
      const errorMessage = `Invalid Call Transaction Request, either ids are null.
      CalledUid: ${calledUid} CallerUid: ${callerUid}`;
      throw new Error(errorMessage);
    }
    const expertRate: ExpertRate = await getExpertRateDocument(
        {transaction: transaction, expertUid: calledUid});
    const calledUserFcmToken: FcmToken = await getFcmTokenDocument({transaction: transaction, uid: calledUid});
    const callerUserInfo: PrivateUserInfo = await getPrivateUserDocument({transaction, uid: callerUid});
    const calledUserInfo: PrivateUserInfo = await getPrivateUserDocument({transaction, uid: calledUid});

    if (!callAllowedStripeConfigValid({callerUserInfo: callerUserInfo, calledUserInfo: calledUserInfo})) {
      return [false, null, null, null, null, null];
    }
    const balanceDoc = await getUserOwedBalanceDocumentRef({uid: callerUid}).get();
    if (balanceDoc.exists) {
      const owedBalance = balanceDoc.data() as UserOwedBalance;
      if (owedBalance.owedBalanceCents != 0) {
        console.error(`Caller: ${callerUid} has a balance of ${owedBalance.owedBalanceCents} cents. Disconnecting from call server`);
        return [false, null, null, null, null, null];
      }
    }

    const maxCallLengthSec = calculateMaxCallLengthSec(
        {centsPerMinute: expertRate.centsPerMinute, centsStartCall: expertRate.centsCallStart, amountAuthorizedCents: amountCentsPreAuth});
    const callTransaction: CallTransaction = createCallTransactionDocument({transaction: transaction, callerUid: callerUid,
      calledUid: calledUid, calledUserFcmToken: calledUserFcmToken, expertRate: expertRate, maxCallTimeSec: maxCallLengthSec});
    const paymentStatus = await createPaymentStatus({transaction: transaction, uid: callerUid,
      paymentStatusId: callTransaction.callerPaymentStatusId, transferGroup: callTransaction.callerTransferGroup, idempotencyKey: uuidv4(),
      centsRequestedAuthorized: amountCentsPreAuth, centsRequestedCapture: 0, paymentContext: PaymentContext.IN_CALL});
    return [true, callTransaction, paymentStatus, callerUserInfo, expertRate];
  });

  if (canCreateCall && userInfo != null && callTransaction != null && paymentStatus != null) {
    const [paymentIntentId, paymentIntentClientSecret] = await createStripePaymentIntentPreAuth({
      customerId: userInfo.stripeCustomerId,
      customerEmail: userInfo.email, amountToAuthInCents: amountCentsPreAuth,
      idempotencyKey: paymentStatus.idempotencyKey, transferGroup: paymentStatus.transferGroup, paymentStatusId: callTransaction.callerPaymentStatusId,
      paymentDescription: "Expert Call", callerUid: callerUid, calledUid: callTransaction.calledUid,
      callTransactionId: callTransaction.callTransactionId});
    await getPaymentStatusDocumentRef({paymentStatusId: callTransaction.callerPaymentStatusId}).update("paymentIntentId", paymentIntentId);

    const ephemeralKey = await createCustomerEphemeralKey({customerId: userInfo.stripeCustomerId});
    return [true, userInfo.stripeCustomerId, paymentIntentClientSecret, ephemeralKey, callTransaction, expertRate];
  }
  return [false, "", "", ""];
};
