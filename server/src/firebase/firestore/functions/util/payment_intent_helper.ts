import {v4 as uuidv4} from "uuid";
import createStripePaymentIntent from "../../../../stripe/payment_intent_creator";
import {PrivateUserInfo} from "../../models/private_user_info";

export type PaymentIntentType = [paymentStatusId: string, paymentIntentClientSecret: string] | string;

export async function paymentIntentHelperFunc({costInCents, privateUserInfo, description}:
    {costInCents: number, privateUserInfo: PrivateUserInfo, description: string}):
    Promise<PaymentIntentType> {
  const paymentStatusId = uuidv4();
  const [paymentIntentValid, paymentIntentErrorMessage, _, paymentIntentClientSecret] =
      await createStripePaymentIntent(privateUserInfo.stripeCustomerId, privateUserInfo.email,
          costInCents, description, paymentStatusId);

  if (!paymentIntentValid) {
    return `Cannot initiate payment start. ${paymentIntentErrorMessage}`;
  }
  return [paymentStatusId, paymentIntentClientSecret];
}
