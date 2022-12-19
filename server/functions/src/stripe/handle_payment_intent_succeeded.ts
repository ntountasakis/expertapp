import * as admin from "firebase-admin";
import {getUserOwedBalanceDocumentTransaction} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {decreaseBalanceOwed} from "../../../shared/src/firebase/firestore/functions/decrease_balance_owed";
import {updatePaymentStatusAmountPaid} from "../../../shared/src/firebase/firestore/functions/update_payment_status_paid";

export async function handlePaymentIntentSucceeded(payload: any): Promise<void> {
  const amount: number = payload.amount;
  const amountReceived: number = payload.amount_received;
  //   const livemode: boolean = payload.livemode;
  const paymentStatusId: string = payload.metadata.payment_status_id;
  const uid: string = payload.metadata.uid;

  if (paymentStatusId == undefined) {
    console.error("Cannot handle PaymentIntent Success. PaymentId undefined");
    return;
  }
  if (uid == undefined) {
    console.error("Cannot handle PaymentIntent Success. Uid undefined");
    return;
  }
  if (amount != amountReceived) {
    console.error(`PaymentStatus ID: ${paymentStatusId} Not paid in full. 
        Expected: ${amount} Received: ${amountReceived}`);
    return;
  }

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const owedBalance = await getUserOwedBalanceDocumentTransaction({transaction: transaction, uid: uid});
      await decreaseBalanceOwed({transaction: transaction, uid: uid, amountPaidCents: amountReceived, owedBalance: owedBalance});
      await updatePaymentStatusAmountPaid({transaction: transaction, paymentStatusId: paymentStatusId, amountPaidCents: amountReceived});
    });
  } catch (error) {
    console.error(`Error in HandlePaymentIntentSuceeded: ${error}`);
  }
}
