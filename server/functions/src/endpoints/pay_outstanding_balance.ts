import * as functions from "firebase-functions";
import {v4 as uuidv4} from "uuid";
import * as admin from "firebase-admin";
import {getPaymentStatusDocumentRef, getPrivateUserDocument, getUserOwedBalanceDocumentRef} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {UserOwedBalance} from "../../../shared/src/firebase/firestore/models/user_owed_balance";
import {PaymentStatus} from "../../../shared/src/firebase/firestore/models/payment_status";
import {createPaymentStatusAndUpdateBalance} from "../../../shared/src/firebase/firestore/functions/create_payment_status_update_balance";
import {createStripePaymentIntent} from "../../../shared/src/stripe/payment_intent_creator";
import cancelStripePaymentIntent from "../../../shared/src/stripe/cancel_payment_intent";
import {PrivateUserInfo} from "../../../shared/src/firebase/firestore/models/private_user_info";
import createCustomerEphemeralKey from "../../../shared/src/stripe/create_customer_ephemeral_key";

export const payOutstandingBalance = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const userUid = context.auth.uid;

  const [newPaymentStatus, userInfo, newPaymentStatusId, paymentIntentToCancel] = await admin.firestore().runTransaction( async (transaction) => {
    const balanceRef = getUserOwedBalanceDocumentRef({uid: userUid});
    const existingBalanceDoc = await transaction.get(balanceRef);
    if (!existingBalanceDoc.exists) {
      console.log(`User ${userUid} has no outstandin balance document. Owes nothing`);
      return [null, null, null, null];
    }
    const existingBalance = existingBalanceDoc.data() as UserOwedBalance;
    if (existingBalance.owedBalanceCents == 0) {
      console.log(`User ${userUid} has a balance of 0`);
      return [null, null, null, null];
    }
    if (existingBalance.paymentStatusIdWaitingForPayment === "") {
      throw new Error(`User ${userUid} has a balance of ${existingBalance.owedBalanceCents} but no associated outstanding payment`);
    }
    const existingPaymentStatusRef = getPaymentStatusDocumentRef({paymentStatusId: existingBalance.paymentStatusIdWaitingForPayment});
    const existingPaymentStatusDoc = await transaction.get(existingPaymentStatusRef);
    if (!existingPaymentStatusDoc.exists) {
      throw new Error(`Cannot find outstanding payment ${existingBalance.paymentStatusIdWaitingForPayment} for user ${userUid}`);
    }
    const existingPaymentStatus = existingPaymentStatusDoc.data() as PaymentStatus;

    const userInfo: PrivateUserInfo = await getPrivateUserDocument({transaction: transaction, uid: userUid});

    transaction.update(existingPaymentStatusRef, {"status": "cancelled"});
    const newPaymentStatusId = uuidv4();
    transaction.update(balanceRef, {"paymentStatusIdWaitingForPayment": newPaymentStatusId});


    const newPaymentStatus: PaymentStatus = await createPaymentStatusAndUpdateBalance({transaction: transaction, uid: userUid,
      transferGroup: existingPaymentStatus.transferGroup, centsCollect: existingBalance.owedBalanceCents,
      paymentStatusId: newPaymentStatusId, errorOnExistingBalance: false});
    const paymentIntentIdToCancel = existingPaymentStatus.paymentIntentId;

    return [newPaymentStatus, userInfo, newPaymentStatusId, paymentIntentIdToCancel];
  });

  if (newPaymentStatus == null) {
    return {owedBalanceCents: 0, clientSecret: "", stripeCustomerId: "", paymentStatusId: ""};
  }
  await cancelStripePaymentIntent({paymentIntentId: paymentIntentToCancel});
  const [paymentIntentId, paymentIntentClientSecret] = await createStripePaymentIntent({
    customerId: userInfo.stripeCustomerId,
    customerEmail: userInfo.email, amountToBillInCents: newPaymentStatus.centsToCollect,
    idempotencyKey: newPaymentStatus.idempotencyKey, transferGroup: newPaymentStatus.transferGroup, paymentStatusId: newPaymentStatusId,
    paymentDescription: "Pay Balance", uid: userUid});
  await getPaymentStatusDocumentRef({paymentStatusId: newPaymentStatusId}).update("paymentIntentId", paymentIntentId);

  const ephemeralKey = await createCustomerEphemeralKey({customerId: userInfo.stripeCustomerId});
  return {owedBalanceCents: newPaymentStatus.centsToCollect, clientSecret: paymentIntentClientSecret, stripeCustomerId: userInfo.stripeCustomerId,
    paymentStatusId: newPaymentStatusId, ephemeralKey: ephemeralKey};
});
