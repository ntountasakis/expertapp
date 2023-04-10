import handleStripeError from "./stripe_error_handler";
import { StripeProvider } from "./stripe_provider";

export default async function createCustomerEphemeralKey({ customerId }: { customerId: string }): Promise<string> {
    let errorMessage = `EphemeralKey create fail for customerId: ${customerId} \n`;
    try {
        const ephemeralKey = await StripeProvider.STRIPE.ephemeralKeys.create({ customer: customerId, }, { apiVersion: StripeProvider.API_VERSION });
        if (ephemeralKey.secret == null) {
            errorMessage += `Secret is null`;
            throw new Error(errorMessage);
        }
        return ephemeralKey.secret;
    } catch (error) {
        errorMessage += handleStripeError("createCustomerEphemeralKey", error);
        throw new Error(errorMessage);
    }
}