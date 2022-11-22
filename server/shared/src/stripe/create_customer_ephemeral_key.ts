import stripe from "stripe";
import { StripeProvider } from "./stripe_provider";

export default async function createCustomerEphemeralKey({ customerId }: { customerId: string }): Promise<string> {
    let errorMessage = `EphemeralKey create fail for customerId: ${customerId} \n`;
    try {
        const ephemeralKey = await StripeProvider.STRIPE.ephemeralKeys.create({ customer: customerId, }, { apiVersion: StripeProvider.API_VERSION });
        if (ephemeralKey.secret == null) {
            errorMessage += `Secret is null`;
            throw new Error(errorMessage);
        }
        console.log(`Client ephemeral key is: ${ephemeralKey.secret}`);
        return ephemeralKey.secret;
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
        throw new Error(errorMessage);
    }
}