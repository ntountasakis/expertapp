import {CallTransaction} from "../../../../../shared/src/firebase/firestore/models/call_transaction";
import {StripeProvider} from "../../../../../shared/src/stripe/stripe_provider";
import {BaseCallState} from "../../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerFeeBreakdowns} from "../../../protos/call_transaction_package/ServerFeeBreakdowns";

export function sendGrpcServerFeeBreakdowns(clientMessageSender: ClientMessageSenderInterface,
    callTransaction: CallTransaction, callState: BaseCallState): void {
  const serverFeeBreakdown : ServerFeeBreakdowns = {
    "paymentProcessorPercentFee": StripeProvider.STRIPE_PERCENT_FEE,
    "paymentProcessorCentsFlatFee": StripeProvider.STRIPE_FLAT_FEE_CENTS,
    "platformPercentFee": StripeProvider.PLATFORM_PERCENT_FEE,
    "earnedCentsStartCall": callTransaction.expertRateCentsCallStart,
    "earnedCentsPerMinute": callTransaction.expertRateCentsPerMinute,
  };
  clientMessageSender.sendServerFeeBreakdowns(serverFeeBreakdown, callState);
}
