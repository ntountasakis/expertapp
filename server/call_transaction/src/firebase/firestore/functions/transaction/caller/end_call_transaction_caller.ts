import * as admin from "firebase-admin";
import {ServerCallSummary} from "../../../../../protos/call_transaction_package/ServerCallSummary";
import {markCallEndGenerateCallSummary} from "../common/mark_call_end_generate_call_summary";
import {CallerCallState} from "../../../../../call_state/caller/caller_call_state";
import {getCallTransactionDocument, getPaymentStatusDocumentTransaction} from "../../../../../../../functions/src/shared/src/firebase/firestore/document_fetchers/fetchers";
import {updatePaymentStatus} from "../../../../../../../functions/src/shared/src/firebase/firestore/functions/update_payment_status";
import {CallTransaction} from "../../../../../../../functions/src/shared/src/firebase/firestore/models/call_transaction";
import {PaymentStatus, PaymentStatusStates, PaymentStatusCancellationReason} from "../../../../../../../functions/src/shared/src/firebase/firestore/models/payment_status";
import {getUtcMsSinceEpoch} from "../../../../../../../functions/src/shared/src/general/utils";
import cancelStripePaymentIntent from "../../../../../../../functions/src/shared/src/stripe/cancel_payment_intent";
import {chargeStripePaymentIntent} from "../../../../../../../functions/src/shared/src/stripe/payment_intent_creator";

export const endCallTransactionCaller = async ({transactionId, callState, clientRequested} :
  {transactionId: string, callState: CallerCallState, clientRequested: boolean})
: Promise<ServerCallSummary> => {
  const [paymentIntentId, callBegan, callSummary] = await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});

    const paymentStatus: PaymentStatus = await getPaymentStatusDocumentTransaction({
      paymentStatusId: callTransaction.callerPaymentStatusId, transaction: transaction});

    const callSummary: ServerCallSummary = await markCallEndGenerateCallSummary(
        {transaction: transaction, callTransaction: callTransaction, endCallTimeUtcMs: getUtcMsSinceEpoch(), callState: callState});
    if (callTransaction.callBeginTimeUtcMs != 0) {
      const costOfCallCents = callSummary.costOfCallCents!;
      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: paymentStatus.paymentStatusCancellationReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: paymentStatus.centsCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: costOfCallCents,
        paymentStatusId: callTransaction.callerPaymentStatusId, chargeId: paymentStatus.chargeId, status: PaymentStatusStates.CAPTURABLE_CHANGE_REQUESTED});
    } else {
      const cancelReason = clientRequested ? PaymentStatusCancellationReason.CALLER_ENDED_CALL_BEFORE_START :
                                             PaymentStatusCancellationReason.CALLED_NEVER_JOINED;
      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: cancelReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: paymentStatus.centsCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: paymentStatus.centsRequestedCapture,
        paymentStatusId: callTransaction.callerPaymentStatusId, chargeId: paymentStatus.chargeId, status: PaymentStatusStates.CANCELLATION_REQUESTED});
    }
    return [paymentStatus.paymentIntentId, callTransaction.callBeginTimeUtcMs != 0, callSummary];
  });
  if (callBegan) {
    await chargeStripePaymentIntent({amountToCaptureInCents: callSummary.costOfCallCents!, paymentIntentId: paymentIntentId});
  } else {
    await cancelStripePaymentIntent({paymentIntentId: paymentIntentId});
  }

  return callSummary;
};
