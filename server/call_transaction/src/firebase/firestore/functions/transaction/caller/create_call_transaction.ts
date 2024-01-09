import {v4 as uuidv4} from "uuid";
import * as admin from "firebase-admin";
import {calculateMaxCallLengthSec, calculatePreAuthAmountForDesiredCallLength} from "../../util/call_cost_calculator";
import {getExpertRateDocument, getFcmTokenDocument, getPrivateUserDocument, getPaymentStatusDocumentRef, getPublicUserDocument} from "../../../../../../../functions/src/shared/src/firebase/firestore/document_fetchers/fetchers";
import {createCallTransactionDocument} from "../../../../../../../functions/src/shared/src/firebase/firestore/functions/create_call_transaction_document";
import {createPaymentStatus} from "../../../../../../../functions/src/shared/src/firebase/firestore/functions/create_payment_status";
import {CallTransaction} from "../../../../../../../functions/src/shared/src/firebase/firestore/models/call_transaction";
import {ExpertRate} from "../../../../../../../functions/src/shared/src/firebase/firestore/models/expert_rate";
import {FcmToken} from "../../../../../../../functions/src/shared/src/firebase/firestore/models/fcm_token";
import {PaymentContext} from "../../../../../../../functions/src/shared/src/firebase/firestore/models/payment_status";
import {PrivateUserInfo} from "../../../../../../../functions/src/shared/src/firebase/firestore/models/private_user_info";
import createCustomerEphemeralKey from "../../../../../../../functions/src/shared/src/stripe/create_customer_ephemeral_key";
import {createStripePaymentIntentPreAuth} from "../../../../../../../functions/src/shared/src/stripe/payment_intent_creator";
import callAllowedStripeConfigValid from "../../util/call_allowed_stripe_config_valid";
import {PublicUserInfo} from "../../../../../../../functions/src/shared/src/firebase/firestore/models/public_user_info";

export const createCallTransaction = async ({callerUid, calledUid}: { callerUid: string, calledUid: string }):
  Promise<[boolean, string, string, string, string, number, CallTransaction?, ExpertRate?]> => {
  const [canCreateCall, callTransaction, paymentStatus, privateCallerUserInfo, publicCallerUserInfo, expertRate, amountCentsPreAuth] =
    await admin.firestore().runTransaction(async (transaction) => {
      if (calledUid == null || calledUid == null) {
        const errorMessage = `Invalid Call Transaction Request, either ids are null.
      CalledUid: ${calledUid} CallerUid: ${callerUid}`;
        throw new Error(errorMessage);
      }
      const expertRate: ExpertRate = await getExpertRateDocument(
          {transaction: transaction, expertUid: calledUid});
      const calledUserFcmToken: FcmToken = await getFcmTokenDocument({transaction: transaction, uid: calledUid});
      const callerPrivateUserInfo: PrivateUserInfo = await getPrivateUserDocument({transaction, uid: callerUid});
      const callerPublicUserInfo: PublicUserInfo = await getPublicUserDocument({transaction, uid: callerUid});
      const calledPrivateUserInfo: PrivateUserInfo = await getPrivateUserDocument({transaction, uid: calledUid});

      if (!callAllowedStripeConfigValid({callerUserInfo: callerPrivateUserInfo, calledUserInfo: calledPrivateUserInfo})) {
        return [false, null, null, null, null, null, 0];
      }
      const amountCentsPreAuth = calculatePreAuthAmountForDesiredCallLength({
        centsPerMinute: expertRate.centsPerMinute,
        centsStartCall: expertRate.centsCallStart, desiredLengthSeconds: 30 * 60,
      });

      const maxCallLengthSec = calculateMaxCallLengthSec(
          {centsPerMinute: expertRate.centsPerMinute, centsStartCall: expertRate.centsCallStart, amountAuthorizedCents: amountCentsPreAuth});
      const callTransaction: CallTransaction = createCallTransactionDocument({
        transaction: transaction, callerUid: callerUid,
        calledUid: calledUid, calledUserFcmToken: calledUserFcmToken, expertRate: expertRate, maxCallTimeSec: maxCallLengthSec,
      });
      const paymentStatus = createPaymentStatus({
        transaction: transaction, uid: callerUid, callTransactionId: callTransaction.callTransactionId,
        paymentStatusId: callTransaction.callerPaymentStatusId, transferGroup: callTransaction.callerTransferGroup, idempotencyKey: uuidv4(),
        centsRequestedAuthorized: amountCentsPreAuth, centsRequestedCapture: 0, paymentContext: PaymentContext.IN_CALL,
      });
      return [true, callTransaction, paymentStatus, callerPrivateUserInfo, callerPublicUserInfo, expertRate, amountCentsPreAuth];
    });

  if (canCreateCall && privateCallerUserInfo != null && publicCallerUserInfo != null && callTransaction != null && paymentStatus != null) {
    const [paymentIntentId, paymentIntentClientSecret] = await createStripePaymentIntentPreAuth({
      customerId: privateCallerUserInfo.stripeCustomerId,
      customerEmail: privateCallerUserInfo.email, amountToAuthInCents: amountCentsPreAuth,
      idempotencyKey: paymentStatus.idempotencyKey, transferGroup: paymentStatus.transferGroup, paymentStatusId: callTransaction.callerPaymentStatusId,
      paymentDescription: "Expert Call", callerUid: callerUid, calledUid: callTransaction.calledUid,
      callTransactionId: callTransaction.callTransactionId,
    });
    await getPaymentStatusDocumentRef({paymentStatusId: callTransaction.callerPaymentStatusId}).update("paymentIntentId", paymentIntentId);

    const ephemeralKey = await createCustomerEphemeralKey({customerId: privateCallerUserInfo.stripeCustomerId});
    return [true, privateCallerUserInfo.stripeCustomerId, paymentIntentClientSecret, ephemeralKey, publicCallerUserInfo.firstName,
      amountCentsPreAuth, callTransaction, expertRate];
  }
  return [false, "", "", "", "", 0];
};
