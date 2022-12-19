import { getUserOwedBalanceDocumentRef } from "../document_fetchers/fetchers";
import { UserOwedBalance } from "../models/user_owed_balance";

export async function decreaseBalanceOwed({ transaction, uid, amountPaidCents: amountPaidCents, owedBalance }:
  { transaction: FirebaseFirestore.Transaction, amountPaidCents: number, uid: string, owedBalance: UserOwedBalance}): Promise<void> {
  if (owedBalance.owedBalanceCents == 0) {
    console.log(`Balance for ${uid} was 0, assuming this payment intentionally not added to balance`);
    return;
  }
  if (owedBalance.owedBalanceCents != amountPaidCents) {
    console.error(`UserOwedBalance ${uid} had a balance of ${owedBalance.owedBalanceCents} however only received ${amountPaidCents}`);
  }
  owedBalance.owedBalanceCents -= amountPaidCents;
  const newBalance = {
    "owedBalanceCents": owedBalance.owedBalanceCents,
    "paymentStatusIdWaitingForPayment": "",
  };
  transaction.update(getUserOwedBalanceDocumentRef({ uid: uid }), newBalance);
}
