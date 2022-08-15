import * as admin from "firebase-admin";

export async function handlePaymentIntentSucceeded(payload: any): Promise<void> {
  const id: string = payload.id;
  const amount: number = payload.amount;
  const amountReceived: number = payload.amount_received;
  //   const livemode: boolean = payload.livemode;
  const status = payload.status;
  const paymentStatusId: string = payload.metadata.payment_status_id;

  if (paymentStatusId == undefined) {
    console.error("Cannot handle PaymentIntent Success. PaymentId undefined");
    return;
  }
  if (amount != amountReceived) {
    console.error(`PaymentStatus ID: ${paymentStatusId} Not paid in full. 
        Expected: ${amount} Received: ${amountReceived}`);
  }

  await admin.firestore().runTransaction(async (transaction) => {
    const paymentCollectionRef = admin.firestore().collection("payment_statuses");
    const paymentStatusDoc = await transaction.get(paymentCollectionRef.doc(paymentStatusId));

    if (!paymentStatusDoc.exists) {
      console.error(`Cannot update PaymentStatus! PaymentIntentId: ${paymentStatusId} not found.`);
      return;
    }
    const paymentDetails = {
      "centsCollected": amountReceived,
      "status": status,
    };
    transaction.update(paymentStatusDoc.ref, paymentDetails);

    console.log(`PaymentIntent Success! ID: ${id} Amount: ${amount} AmountReceived: ${amountReceived} Status: ${status} 
    PaymentId: ${paymentStatusId}`);
  });
}
