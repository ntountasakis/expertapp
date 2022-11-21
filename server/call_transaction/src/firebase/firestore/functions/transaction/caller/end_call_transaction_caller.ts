import * as admin from "firebase-admin";
import {getCallTransactionDocument, getPaymentStatusDocumentRef, getPrivateUserDocument} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {calculateCostOfCallInCents} from "../../util/call_cost_calculator";
import {markCallEnd} from "../../util/call_transaction_complete";
import {PrivateUserInfo} from "../../../../../../../shared/src/firebase/firestore/models/private_user_info";
import createStripePaymentIntent from "../../../../../../../shared/src/stripe/payment_intent_creator";
import {createPaymentStatusAndUpdateBalance} from "../../../../../../../shared/src/firebase/firestore/functions/create_payment_status_update_balance";

export const endCallTransactionCaller = async ({transactionId} : {transactionId: string})
: Promise<[CallTransaction, string, string, number]> => {
  const [callTransaction, paymentStatus, userInfo] = await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});

    const endTimeUtcMs = callTransaction.callHasEnded ? callTransaction.callEndTimeUtsMs : Date.now();
    const userInfo: PrivateUserInfo = await getPrivateUserDocument({transaction, uid: callTransaction.callerUid});
    let paymentStatus = null;

    if (callTransaction.calledHasJoined) {
      const costOfCallInCents = calculateCostOfCallInCents({
        beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs,
        endTimeUtcMs: endTimeUtcMs,
        centsPerMinute: callTransaction.expertRateCentsPerMinute,
      });
      paymentStatus = await createPaymentStatusAndUpdateBalance({transaction: transaction,
        uid: callTransaction.callerUid, transferGroup: callTransaction.callerTransferGroup, centsCollect: costOfCallInCents,
        paymentStatusId: callTransaction.callerCallTerminatePaymentStatusId, errorOnExistingBalance: true});
    }

    if (!callTransaction.callHasEnded) {
      markCallEnd(callTransaction.callTransactionId, endTimeUtcMs, transaction);
    }

    return [callTransaction, paymentStatus, userInfo];
  });
  let clientSecret = "";
  let amountOwedCents = 0;
  if (paymentStatus != null) {
    const [paymentIntentId, paymentIntentClientSecret] = await createStripePaymentIntent({
      customerId: userInfo.stripeCustomerId,
      customerEmail: userInfo.email, amountToBillInCents: paymentStatus.centsToCollect,
      idempotencyKey: paymentStatus.idempotencyKey, transferGroup: paymentStatus.transferGroup,
      paymentStatusId: callTransaction.callerCallTerminatePaymentStatusId, paymentDescription: "Call Begin",
      uid: callTransaction.callerUid});
    await getPaymentStatusDocumentRef({paymentStatusId: callTransaction.callerCallTerminatePaymentStatusId}).update("paymentIntentId", paymentIntentId);
    clientSecret = paymentIntentClientSecret;
    amountOwedCents = paymentStatus.centsToCollect;
  }

  return [callTransaction, userInfo.stripeCustomerId, clientSecret, amountOwedCents];
};
