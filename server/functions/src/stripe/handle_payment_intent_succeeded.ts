import * as admin from "firebase-admin";
import {getPaymentStatusDocumentTransaction, getUserOwedBalanceDocumentTransaction} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {decreaseBalanceOwed} from "../../../shared/src/firebase/firestore/functions/decrease_balance_owed";
import {updatePaymentStatus} from "../../../shared/src/firebase/firestore/functions/update_payment_status";
import {PaymentStatusStates} from "../../../shared/src/firebase/firestore/models/payment_status";

export async function handlePaymentIntentSucceeded(payload: any): Promise<void> {
  //   const livemode: boolean = payload.livemode;
  const amountPaid: number = payload.amount_received;
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

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const owedBalance = await getUserOwedBalanceDocumentTransaction({transaction: transaction, uid: uid});
      const paymentStatus = await getPaymentStatusDocumentTransaction({transaction: transaction, paymentStatusId: paymentStatusId});
      await decreaseBalanceOwed({transaction: transaction, uid: uid, amountPaidCents: amountPaid, owedBalance: owedBalance});
      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: paymentStatus.paymentStatusCancellationReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: paymentStatus.centsCaptured, centsPaid: amountPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: paymentStatus.centsRequestedCapture,
        paymentStatusId: paymentStatusId, chargeId: paymentStatus.chargeId, status: PaymentStatusStates.PAID});
    });
  } catch (error) {
    console.error(`Error in HandlePaymentIntentSuceeded: ${error}`);
  }
}
