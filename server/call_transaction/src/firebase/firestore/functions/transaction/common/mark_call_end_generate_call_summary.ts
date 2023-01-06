import {getCallTransactionDocumentRef} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {StripeProvider} from "../../../../../../../shared/src/stripe/stripe_provider";
import {ServerCallSummary} from "../../../../../protos/call_transaction_package/ServerCallSummary";
import {calculateCostOfCallInCents, calculateEarnedCents, calculatePaymentProcessorFeeCents, calculatePlatformFeeCents} from "../../util/call_cost_calculator";

export const markCallEndGenerateCallSummary = async ({transaction, callTransaction, endCallTimeUtcMs}:
    {transaction: FirebaseFirestore.Transaction, callTransaction: CallTransaction, endCallTimeUtcMs: number}): Promise<ServerCallSummary> => {
  if (!callTransaction.callHasEnded && callTransaction.calledHasJoined) {
    const lengthOfCallSec: number = (endCallTimeUtcMs - callTransaction.calledJoinTimeUtcMs) / 1000;
    const costOfCall: number = calculateCostOfCallInCents({beginTimeUtcMs: callTransaction.calledJoinTimeUtcMs, endTimeUtcMs: endCallTimeUtcMs,
      centsPerMinute: callTransaction.expertRateCentsPerMinute, centsStartCall: callTransaction.expertRateCentsCallStart});
    const platformFees: number = calculatePlatformFeeCents({costOfCallCents: costOfCall, platformFeePercent: StripeProvider.PLATFORM_PERCENT_FEE});
    const paymentProcessorFees: number = calculatePaymentProcessorFeeCents({costOfCallCents: costOfCall,
      processorFeePercent: StripeProvider.STRIPE_PERCENT_FEE, processorFlatFeeCents: StripeProvider.STRIPE_FLAT_FEE_CENTS});
    const earnedTotal: number = calculateEarnedCents({costOfCallCents: costOfCall, platformFeeCents: platformFees, processorFeeCents: paymentProcessorFees});
    transaction.update(getCallTransactionDocumentRef({transactionId: callTransaction.callTransactionId}), {
      "callHasEnded": true,
      "callEndTimeUtsMs": endCallTimeUtcMs,
      "lengthOfCallSec": lengthOfCallSec,
      "costOfCallCents": costOfCall,
      "paymentProcessorFeeCents": paymentProcessorFees,
      "platformFeeCents": platformFees,
      "earnedTotalCents": earnedTotal,
    });
    callTransaction.callHasEnded = true;
    callTransaction.callEndTimeUtsMs = endCallTimeUtcMs;
    callTransaction.lengthOfCallSec = lengthOfCallSec;
    callTransaction.costOfCallCents = costOfCall;
    callTransaction.paymentProcessorFeeCents = paymentProcessorFees;
    callTransaction.platformFeeCents = platformFees;
    callTransaction.earnedTotalCents = earnedTotal;
  }
  return {
    "lengthOfCallSec": callTransaction.lengthOfCallSec,
    "costOfCallCents": callTransaction.costOfCallCents,
    "paymentProcessorFeeCents": callTransaction.paymentProcessorFeeCents,
    "platformFeeCents": callTransaction.platformFeeCents,
    "earnedTotalCents": callTransaction.earnedTotalCents,
  };
};
