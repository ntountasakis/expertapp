import {StripeProvider} from "../../../shared/stripe/stripe_provider";
export default async function createStripePaymentTransfer({connectedAccountId, amountToTransferInCents, transferGroup}:
    {connectedAccountId: string, amountToTransferInCents: number, transferGroup: string}): Promise<string> {
  // eslint-disable-next-line max-len
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
}
