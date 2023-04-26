import {getCallTransactionDocumentRef, getPublicExpertInfoDocumentRef} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {StripeProvider} from "../../../../../../../shared/src/stripe/stripe_provider";
import {CallerCallState} from "../../../../../call_state/caller/caller_call_state";
import {BaseCallState} from "../../../../../call_state/common/base_call_state";
import {ServerCallSummary} from "../../../../../protos/call_transaction_package/ServerCallSummary";
import {calculateCostOfCallInCents, calculateEarnedCents, calculatePaymentProcessorFeeCents, calculatePlatformFeeCents} from "../../util/call_cost_calculator";

export const markCallEndGenerateCallSummary = async ({transaction, callTransaction, endCallTimeUtcMs, callState}:
    {transaction: FirebaseFirestore.Transaction, callTransaction: CallTransaction, endCallTimeUtcMs: number,
      callState: BaseCallState}): Promise<ServerCallSummary> => {
  const transactionDocumentRef = getCallTransactionDocumentRef({transactionId: callTransaction.callTransactionId});
  const publicExpertInfoDocumentRef = getPublicExpertInfoDocumentRef({uid: callTransaction.calledUid, fromSignUpFlow: false});
  if (callTransaction.callBeginTimeUtcMs !=0) {
    const lengthOfCallSec: number = (endCallTimeUtcMs - callTransaction.callBeginTimeUtcMs) / 1000;
    const costOfCall: number = calculateCostOfCallInCents({beginTimeUtcMs: callTransaction.callBeginTimeUtcMs, endTimeUtcMs: endCallTimeUtcMs,
      centsPerMinute: callTransaction.expertRateCentsPerMinute, centsStartCall: callTransaction.expertRateCentsCallStart});
    const platformFees: number = await calculatePlatformFeeCents({costOfCallCents: costOfCall, platformFeePercent: StripeProvider.PLATFORM_PERCENT_FEE,
      callState: callState});
    const paymentProcessorFees: number = await calculatePaymentProcessorFeeCents({costOfCallCents: costOfCall,
      processorFeePercent: StripeProvider.STRIPE_PERCENT_FEE, processorFlatFeeCents: StripeProvider.STRIPE_FLAT_FEE_CENTS, callState: callState});
    const earnedTotal: number = await calculateEarnedCents({costOfCallCents: costOfCall,
      platformFeeCents: platformFees, processorFeeCents: paymentProcessorFees, callState: callState});
    transaction.update(transactionDocumentRef, {
      "callEndTimeUtcMs": endCallTimeUtcMs,
      "lengthOfCallSec": lengthOfCallSec,
      "costOfCallCents": costOfCall,
      "paymentProcessorFeeCents": paymentProcessorFees,
      "platformFeeCents": platformFees,
      "earnedTotalCents": earnedTotal,
    });
    callTransaction.callEndTimeUtcMs = endCallTimeUtcMs;
    callTransaction.lengthOfCallSec = lengthOfCallSec;
    callTransaction.costOfCallCents = costOfCall;
    callTransaction.paymentProcessorFeeCents = paymentProcessorFees;
    callTransaction.platformFeeCents = platformFees;
    callTransaction.earnedTotalCents = earnedTotal;
  }
  if (callState instanceof CallerCallState) {
    transaction.update(transactionDocumentRef, {
      "callerFinishedTransaction": true,
    });
  } else {
    transaction.update(transactionDocumentRef, {
      "calledFinishedTransaction": true,
    });
  }
  transaction.update(publicExpertInfoDocumentRef, {
    "inCall": false,
  });
  return {
    "lengthOfCallSec": callTransaction.lengthOfCallSec,
    "costOfCallCents": callTransaction.costOfCallCents,
    "paymentProcessorFeeCents": callTransaction.paymentProcessorFeeCents,
    "platformFeeCents": callTransaction.platformFeeCents,
    "earnedTotalCents": callTransaction.earnedTotalCents,
  };
};
