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
import {updatePaymentStatus} from "../../../../../../../shared/src/firebase/firestore/functions/update_payment_status";
import {CallerCallState} from "../../../../../call_state/caller/caller_call_state";

export const endCallTransactionCaller = async ({transactionId, callState} : {transactionId: string, callState: CallerCallState})
: Promise<void> => {
  const [paymentIntentId, costOfCallInCents, calledJoined] = await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});

    const paymentStatus: PaymentStatus = await getPaymentStatusDocumentTransaction({
      paymentStatusId: callTransaction.callerPaymentStatusId, transaction: transaction});

    const userOwed: UserOwedBalance = await getUserOwedBalanceDocumentTransaction({
      uid: callTransaction.callerUid, transaction: transaction});

    const endTimeUtcMs = callTransaction.callHasEnded ? callTransaction.callEndTimeUtsMs : Date.now();
    let costOfCallInCents = 0;
    if (callTransaction.calledHasJoined) {
      costOfCallInCents = calculateCostOfCallInCents({
        beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs,
        endTimeUtcMs: endTimeUtcMs,
        centsPerMinute: callTransaction.expertRateCentsPerMinute,
        centsStartCall: callTransaction.expertRateCentsCallStart,
      });
      await increaseBalanceOwed({transaction: transaction, owedBalance: userOwed, uid: callTransaction.callerUid,
        centsCollect: costOfCallInCents, paymentStatusId: callTransaction.callerPaymentStatusId, errorOnExistingBalance: true});
      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: paymentStatus.paymentStatusCancellationReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: paymentStatus.centsCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: costOfCallInCents,
        paymentStatusId: callTransaction.callerPaymentStatusId, status: PaymentStatusStates.CAPTURABLE_CHANGE_REQUESTED});
    } else {
      const cancelReason = callState.isConnected ? PaymentStatusCancellationReason.CALLED_NEVER_JOINED :
                                                   PaymentStatusCancellationReason.CALLER_ENDED_CALL_BEFORE_START;
      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: cancelReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: paymentStatus.centsCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: paymentStatus.centsRequestedCapture,
        paymentStatusId: callTransaction.callerPaymentStatusId, status: PaymentStatusStates.CANCELLATION_REQUESTED});
    }
    if (!callTransaction.callHasEnded) {
      markCallEnd(callTransaction.callTransactionId, endTimeUtcMs, transaction);
    }
    return [paymentStatus.paymentIntentId, costOfCallInCents, callTransaction.calledHasJoined];
  });
  if (calledJoined) {
    await chargeStripePaymentIntent({amountToCaptureInCents: costOfCallInCents, paymentIntentId: paymentIntentId});
  } else {
    await cancelStripePaymentIntent({paymentIntentId: paymentIntentId});
  }
};
