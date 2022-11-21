import {v4 as uuidv4} from "uuid";
import {getUserOwedBalanceDocumentRef} from "../document_fetchers/fetchers";
import {createPaymentStatus} from "./create_payment_status";
import {PaymentStatus} from "../models/payment_status";
import {UserOwedBalance} from "../models/user_owed_balance";

export async function createPaymentStatusAndUpdateBalance({transaction, uid, paymentStatusId, transferGroup, centsCollect, errorOnExistingBalance}:
    {transaction : FirebaseFirestore.Transaction, uid: string, paymentStatusId: string, transferGroup: string,
        centsCollect: number, errorOnExistingBalance: boolean}): Promise<PaymentStatus> {
  const owedBalanceRef = getUserOwedBalanceDocumentRef({uid: uid});
  const owedBalanceDoc = await owedBalanceRef.get();

  const paymentStatus: PaymentStatus = createPaymentStatus({transaction, uid: uid, paymentStatusId: paymentStatusId,
    transferGroup: transferGroup, idempotencyKey: uuidv4(), costInCents: centsCollect});
  if (owedBalanceDoc.exists) {
    const owedBalance: UserOwedBalance = owedBalanceDoc.data() as UserOwedBalance;

    if (owedBalance.owedBalanceCents != 0 && errorOnExistingBalance) {
      throw new Error(`Cannot add additional charge. User ${uid} already has a owed balance of ${owedBalance} cents`);
    }
  }
  const newOwedBalance: UserOwedBalance = {
    "owedBalanceCents": centsCollect,
    "paymentStatusIdWaitingForPayment": paymentStatusId,
  };
  owedBalanceRef.set(newOwedBalance);
  return paymentStatus;
}
