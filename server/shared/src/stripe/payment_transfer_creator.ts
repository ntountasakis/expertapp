import handleStripeError from "./stripe_error_handler";
import { StripeProvider } from "./stripe_provider";

export default async function createStripePaymentTransfer({ connectedAccountId, amountToTransferInCents, transferGroup }:
  { connectedAccountId: string, amountToTransferInCents: number, transferGroup: string }): Promise<string> {
  // eslint-disable-next-line max-len

  let errorMessage = `Transfer cancel fail for connectedAccountId: ${connectedAccountId} transferGroup: ${transferGroup} \n`;
  try {
    const paymentTransferResponse = await StripeProvider.STRIPE.transfers.create({
      amount: amountToTransferInCents,
      currency: "usd",
      destination: connectedAccountId,
      transfer_group: transferGroup,
    },
      {
        idempotencyKey: transferGroup,
      });
    return paymentTransferResponse.id;
  } catch (error) {
    errorMessage += handleStripeError(error);
  }
  throw new Error(errorMessage);
}
