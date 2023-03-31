import handleStripeError from "./stripe_error_handler";
import { StripeProvider } from "./stripe_provider";

export default async function createCustomerManagePaymentMethodsDashboardLoginLink({ customerAccountId }: { customerAccountId: string }): Promise<string> {
    let errorMessage = 'Stripe login link url failure for customer account id: ' + customerAccountId + ' ';
    try {
        const loginLink = await StripeProvider.STRIPE.billingPortal.sessions.create({ customer: customerAccountId });
        if (!loginLink.url) {
            errorMessage += 'url is null';
            throw new Error(errorMessage);
        }
        return loginLink.url;
    } catch (error) {
        errorMessage += handleStripeError(error);
        throw new Error(errorMessage);
    }
}