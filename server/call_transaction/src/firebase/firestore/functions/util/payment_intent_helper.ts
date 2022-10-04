import {v4 as uuidv4} from "uuid";
import {getPaymentStatusDocumentRef} from "../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {PaymentStatus} from "../../../../../../shared/firebase/firestore/models/payment_status";
import {PrivateUserInfo} from "../../../../../../shared/firebase/firestore/models/private_user_info";
import createStripePaymentIntent from "../../../../stripe/payment_intent_creator";

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

  const callStartPaymentDoc = getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId});
  transaction.create(callStartPaymentDoc, callerCallStartPaymentStatus);

  console.log(`Created PaymentStatus. ID: ${paymentStatusId} CentsToCollect: ${costInCents} Uid: ${uid}`);

  return [paymentStatusId, paymentIntentClientSecret];
}
