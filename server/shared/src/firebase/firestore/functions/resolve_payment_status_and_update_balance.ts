import { getPaymentStatusDocumentRef, getUserOwedBalanceDocumentRef } from "../document_fetchers/fetchers";
import { UserOwedBalance } from "../models/user_owed_balance";

export async function resolvePaymentStatusAndUpdateBalance({transaction, uid, paymentStatusId, amountReceived, status}:
    {transaction: FirebaseFirestore.Transaction, paymentStatusId: string, amountReceived: number,
    status: string, uid: string}): Promise<void> {
  const paymentStatusDoc = await transaction.get(getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId}));
  const owedBalanceDoc = await transaction.get(getUserOwedBalanceDocumentRef({uid: uid}));

  if (!paymentStatusDoc.exists) {
    throw new Error(`Cannot update PaymentStatus! PaymentIntentId: ${paymentStatusId} not found.`);
  }
  const paymentDetails = {
    "centsCollected": amountReceived,
    "status": status,
  };
  transaction.update(paymentStatusDoc.ref, paymentDetails);

  if (!owedBalanceDoc.exists) {
    console.log(`No owed balance document for user: ${uid}, assuming this payment intentionally not added to balance`);
    return;
  }

  const existingBalance = owedBalanceDoc.data() as UserOwedBalance;
  if (existingBalance.owedBalanceCents == 0)
  {
    console.log(`Balance for ${uid} was 0, assuming this payment intentionally not added to balance`);
    return;
  }
  if (existingBalance.owedBalanceCents != amountReceived)
  {
    throw new Error(`UserOwedBalance ${uid} had a balance of ${existingBalance.owedBalanceCents} however only received ${amountReceived}`);
  }
  const newBalance = {
    "owedBalanceCents": 0,
    "paymentStatusIdWaitingForPayment": "",
  };
  transaction.update(owedBalanceDoc.ref, newBalance);
}
