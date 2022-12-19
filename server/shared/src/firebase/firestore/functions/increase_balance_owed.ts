import { getUserOwedBalanceDocumentRef } from "../document_fetchers/fetchers";
import { UserOwedBalance } from "../models/user_owed_balance";

export async function increaseBalanceOwed({ uid, paymentStatusId, centsCollect, errorOnExistingBalance, owedBalance }:
  { owedBalance: UserOwedBalance, uid: string, paymentStatusId: string, centsCollect: number,
    errorOnExistingBalance: boolean }): Promise<void> {

  if (owedBalance.owedBalanceCents != 0 && errorOnExistingBalance) {
    throw new Error(`Cannot add additional charge. User ${uid} already has a owed balance of ${owedBalance} cents`);
  }
  const newOwedBalance: UserOwedBalance = {
    "owedBalanceCents": centsCollect,
    "paymentStatusIdWaitingForPayment": paymentStatusId,
  };
  getUserOwedBalanceDocumentRef({ uid: uid }).set(newOwedBalance);
}
