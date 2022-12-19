import * as admin from "firebase-admin";
import {getCallTransactionDocument, getPaymentStatusDocumentTransaction, getUserOwedBalanceDocumentTransaction} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {calculateCostOfCallInCents} from "../../util/call_cost_calculator";
import {markCallEnd} from "../../util/call_transaction_complete";
import {chargeStripePaymentIntent} from "../../../../../../../shared/src/stripe/payment_intent_creator";
import {increaseBalanceOwed} from "../../../../../../../shared/src/firebase/firestore/functions/increase_balance_owed";
import {PaymentStatus, PaymentStatusCancellationReason, PaymentStatusStates} from "../../../../../../../shared/src/firebase/firestore/models/payment_status";
import cancelStripePaymentIntent from "../../../../../../../shared/src/stripe/cancel_payment_intent";
import {UserOwedBalance} from "../../../../../../../shared/src/firebase/firestore/models/user_owed_balance";
import {updatePaymentStatusAmountCharged} from "../../../../../../../shared/src/firebase/firestore/functions/update_payment_status_charged";
import {updatePaymentStatusAmountAuthorized} from "../../../../../../../shared/src/firebase/firestore/functions/update_payment_status_authorized";
import {updatePaymentStatusCancelled} from "../../../../../../../shared/src/firebase/firestore/functions/update_payment_status_cancelled";

export const endCallTransactionCaller = async ({transactionId} : {transactionId: string})
: Promise<void> => {
  const [paymentStatus, callTransaction] = await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});

    const paymentStatus: PaymentStatus = await getPaymentStatusDocumentTransaction({
      paymentStatusId: callTransaction.callerPaymentStatusId, transaction: transaction});

    const userOwed: UserOwedBalance = await getUserOwedBalanceDocumentTransaction({
      uid: callTransaction.callerUid, transaction: transaction});

    const endTimeUtcMs = callTransaction.callHasEnded ? callTransaction.callEndTimeUtsMs : Date.now();

    if (callTransaction.calledHasJoined) {
      const costOfCallInCents = calculateCostOfCallInCents({
        beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs,
        endTimeUtcMs: endTimeUtcMs,
        centsPerMinute: callTransaction.expertRateCentsPerMinute,
      });
      await increaseBalanceOwed({owedBalance: userOwed, uid: callTransaction.callerUid,
        centsCollect: costOfCallInCents, paymentStatusId: callTransaction.callerPaymentStatusId, errorOnExistingBalance: true});
      await updatePaymentStatusAmountCharged({transaction: transaction, paymentStatus: paymentStatus,
        paymentStatusId: callTransaction.callerPaymentStatusId, amountChargedCents: costOfCallInCents, status: PaymentStatusStates.CHARGE_REQUESTED});
    } else {
      await updatePaymentStatusCancelled({transaction: transaction, paymentStatusId: callTransaction.callerPaymentStatusId,
        reason: PaymentStatusCancellationReason.CALLED_NEVER_JOINED});
    }
    if (!callTransaction.callHasEnded) {
      markCallEnd(callTransaction.callTransactionId, endTimeUtcMs, transaction);
    }
    return [paymentStatus, callTransaction];
  });
  if (paymentStatus != null) {
    if (callTransaction.calledHasJoined) {
      await chargeStripePaymentIntent({amountToCaptureInCents: paymentStatus.centsCharged, paymentIntentId: paymentStatus.paymentIntentId});
    } else {
      await cancelStripePaymentIntent({paymentIntentId: paymentStatus.paymentIntentId});
    }
  }
};
