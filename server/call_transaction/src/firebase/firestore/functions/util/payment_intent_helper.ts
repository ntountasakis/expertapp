import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";
import createStripePaymentIntent from "../../../../stripe/payment_intent_creator";
import {PaymentStatus} from "../../models/payment_status";
import {PrivateUserInfo} from "../../models/private_user_info";

export type PaymentIntentType = [paymentStatusId: string, paymentIntentClientSecret: string] | string;

export async function paymentIntentHelperFunc(
    {costInCents, privateUserInfo, uid, transferGroup, description, transaction}:
    {costInCents: number, privateUserInfo: PrivateUserInfo, description: string,
      uid: string, transferGroup: string, transaction: FirebaseFirestore.Transaction}):
    Promise<PaymentIntentType> {
  const paymentStatusId = uuidv4();
  const [paymentIntentValid, paymentIntentErrorMessage, _, paymentIntentClientSecret] =
      await createStripePaymentIntent({customerId: privateUserInfo.stripeCustomerId,
        customerEmail: privateUserInfo.email, amountToBillInCents: costInCents,
        paymentDescription: description, paymentStatusId: paymentStatusId, transferGroup: transferGroup});

  if (!paymentIntentValid) {
    return `Cannot initiate payment start. ${paymentIntentErrorMessage}`;
  }

  const callerCallStartPaymentStatus: PaymentStatus = {
    "uid": uid,
    "status": "awaiting_payment",
    "transferGroup": transferGroup,
    "centsToCollect": costInCents,
    "centsCollected": 0,
  };

  const callStartPaymentDoc = admin.firestore().collection("payment_statuses").doc(paymentStatusId);
  transaction.create(callStartPaymentDoc, callerCallStartPaymentStatus);

  console.log(`Created PaymentStatus. ID: ${paymentStatusId} CentsToCollect: ${costInCents} Uid: ${uid}`);

  return [paymentStatusId, paymentIntentClientSecret];
}
