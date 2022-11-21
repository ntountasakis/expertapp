import stripe from "stripe";
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
    if (error instanceof stripe.errors.StripeAPIError) {
      errorMessage += `Api Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
    } else if (error instanceof stripe.errors.StripeInvalidRequestError) {
      errorMessage += `Invalid Request Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
    } else if (error instanceof stripe.errors.StripeCardError) {
      errorMessage += `Card Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
    } else if (error instanceof stripe.errors.StripeIdempotencyError) {
      errorMessage += `Idempotency Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
    } else {
      errorMessage += `Unhandled Error Type ${error}`;
    }
  }
  throw new Error(errorMessage);
}
