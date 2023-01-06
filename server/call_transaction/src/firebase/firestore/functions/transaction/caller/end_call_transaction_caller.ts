import * as admin from "firebase-admin";
import {getCallTransactionDocument, getPaymentStatusDocumentTransaction, getUserOwedBalanceDocumentTransaction} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {chargeStripePaymentIntent} from "../../../../../../../shared/src/stripe/payment_intent_creator";
import {increaseBalanceOwed} from "../../../../../../../shared/src/firebase/firestore/functions/increase_balance_owed";
import {PaymentStatus, PaymentStatusCancellationReason, PaymentStatusStates} from "../../../../../../../shared/src/firebase/firestore/models/payment_status";
import cancelStripePaymentIntent from "../../../../../../../shared/src/stripe/cancel_payment_intent";
import {UserOwedBalance} from "../../../../../../../shared/src/firebase/firestore/models/user_owed_balance";
import {updatePaymentStatus} from "../../../../../../../shared/src/firebase/firestore/functions/update_payment_status";
import {CallerCallState} from "../../../../../call_state/caller/caller_call_state";
import {getUtcMsSinceEpoch} from "../../../../../../../shared/src/general/utils";
import {sendFcmCallJoinCancel} from "../../../../../../../shared/src/firebase/fcm/functions/send_fcm_call_join_request";
import {ServerCallSummary} from "../../../../../protos/call_transaction_package/ServerCallSummary";
import {markCallEndGenerateCallSummary} from "../common/mark_call_end_generate_call_summary";

export const endCallTransactionCaller = async ({transactionId, callState} : {transactionId: string, callState: CallerCallState})
: Promise<ServerCallSummary> => {
  const [paymentIntentId, calledJoined, calledFcmToken, callSummary] = await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});

    const paymentStatus: PaymentStatus = await getPaymentStatusDocumentTransaction({
      paymentStatusId: callTransaction.callerPaymentStatusId, transaction: transaction});

    const userOwed: UserOwedBalance = await getUserOwedBalanceDocumentTransaction({
      uid: callTransaction.callerUid, transaction: transaction});

    const callSummary: ServerCallSummary = await markCallEndGenerateCallSummary(
        {transaction: transaction, callTransaction: callTransaction, endCallTimeUtcMs: getUtcMsSinceEpoch()});
    const costOfCallCents = callSummary.costOfCallCents!;
    if (callTransaction.calledHasJoined) {
      await increaseBalanceOwed({transaction: transaction, owedBalance: userOwed, uid: callTransaction.callerUid,
        centsCollect: costOfCallCents, paymentStatusId: callTransaction.callerPaymentStatusId, errorOnExistingBalance: true});
      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: paymentStatus.paymentStatusCancellationReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: paymentStatus.centsCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: costOfCallCents,
        paymentStatusId: callTransaction.callerPaymentStatusId, chargeId: paymentStatus.chargeId, status: PaymentStatusStates.CAPTURABLE_CHANGE_REQUESTED});
    } else {
      const cancelReason = callState.isConnected ? PaymentStatusCancellationReason.CALLED_NEVER_JOINED :
                                                   PaymentStatusCancellationReason.CALLER_ENDED_CALL_BEFORE_START;
      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: cancelReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: paymentStatus.centsCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: paymentStatus.centsRequestedCapture,
        paymentStatusId: callTransaction.callerPaymentStatusId, chargeId: paymentStatus.chargeId, status: PaymentStatusStates.CANCELLATION_REQUESTED});
    }
    return [paymentStatus.paymentIntentId, callTransaction.calledHasJoined, callTransaction.calledFcmToken, callSummary];
  });
  if (calledJoined) {
    await chargeStripePaymentIntent({amountToCaptureInCents: callSummary.costOfCallCents!, paymentIntentId: paymentIntentId});
  } else {
    sendFcmCallJoinCancel({fcmToken: calledFcmToken});
    await cancelStripePaymentIntent({paymentIntentId: paymentIntentId});
  }
  return callSummary;
};
