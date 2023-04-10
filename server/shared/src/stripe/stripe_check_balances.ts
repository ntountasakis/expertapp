import Stripe from "stripe";
import handleStripeError from "./stripe_error_handler";

function convertCentsToDollars(cents: number): string {
    return (cents / 100).toFixed(2);
}

function formatAvailableFunds(availableFunds: Stripe.Balance.Available[]): string {
    let msg = "";
    availableFunds.forEach((availableFund) => {
        if (availableFund.amount != 0) {
            const currency = availableFund.currency.toUpperCase();

            if (availableFund.source_types != null && availableFund.source_types.bank_account != null) {
                msg += `${convertCentsToDollars(availableFund.source_types.bank_account)} ${currency} available to bank account. `;
            }

            if (availableFund.source_types != null && availableFund.source_types.card != null) {
                msg += `${convertCentsToDollars(availableFund.source_types.card)} ${currency} available to card. `;
            }

            if (availableFund.source_types != null && availableFund.source_types.fpx != null) {
                msg += `${convertCentsToDollars(availableFund.source_types.fpx)} ${currency} available to fpx. `;
            }
        }
    });
    return msg;
}

function formatPendingFunds(pendingFunds: Stripe.Balance.Pending[]): string {
    let msg = "";
    pendingFunds.forEach((pendingFund) => {
        if (pendingFund.amount != 0) {
            const currency = pendingFund.currency.toUpperCase();

            if (pendingFund.source_types != null && pendingFund.source_types.bank_account != null) {
                msg += `${convertCentsToDollars(pendingFund.source_types.bank_account)} ${currency} pending to bank account. `;
            }

            if (pendingFund.source_types != null && pendingFund.source_types.card != null) {
                msg += `${convertCentsToDollars(pendingFund.source_types.card)} ${currency} pending to card. `;
            }

            if (pendingFund.source_types != null && pendingFund.source_types.fpx != null) {
                msg += `${convertCentsToDollars(pendingFund.source_types.fpx)} ${currency} pending to fpx. `;
            }
        }
    });
    return msg;
}

function formatInstantAvailableFunds(instantAvailableFunds: Stripe.Balance.InstantAvailable[]): string {
    let msg = "";
    instantAvailableFunds.forEach((instantAvailableFund) => {
        if (instantAvailableFund.amount != 0) {
            const currency = instantAvailableFund.currency.toUpperCase();

            if (instantAvailableFund.source_types != null && instantAvailableFund.source_types.bank_account != null) {
                msg += `${convertCentsToDollars(instantAvailableFund.source_types.bank_account)} ${currency} instant available to bank account. `;
            }

            if (instantAvailableFund.source_types != null && instantAvailableFund.source_types.card != null) {
                msg += `${convertCentsToDollars(instantAvailableFund.source_types.card)} ${currency} instant available to card. `;
            }

            if (instantAvailableFund.source_types != null && instantAvailableFund.source_types.fpx != null) {
                msg += `${convertCentsToDollars(instantAvailableFund.source_types.fpx)} ${currency} instant available to fpx. `;
            }
        }

    });
    return msg;
}

function formatConnectReservedFunds(connectReservedFunds: Stripe.Balance.ConnectReserved[]): string {
    let msg = "";
    connectReservedFunds.forEach((connectReservedFund) => {
        if (connectReservedFund.amount != 0) {
            const currency = connectReservedFund.currency.toUpperCase();

            if (connectReservedFund.source_types != null && connectReservedFund.source_types.bank_account != null) {
                msg += `${convertCentsToDollars(connectReservedFund.source_types.bank_account)} ${currency} connect reserved to bank account. `;
            }

            if (connectReservedFund.source_types != null && connectReservedFund.source_types.card != null) {
                msg += `${convertCentsToDollars(connectReservedFund.source_types.card)} ${currency} connect reserved to card. `;
            }

            if (connectReservedFund.source_types != null && connectReservedFund.source_types.fpx != null) {
                msg += `${convertCentsToDollars(connectReservedFund.source_types.fpx)} ${currency} connect reserved to fpx. `;
            }

        }
    });
    return msg;
}

export default async function allBalancesZeroStripeConnectedAccount({ stripe, connectedAccountId }:
    { stripe: Stripe, connectedAccountId: string }): Promise<[boolean, string]> {
    let errorMessage = "Cannot fetch Stripe balance for connectedAccountId. " + connectedAccountId;
    try {
        const balance = await stripe.balance.retrieve({
            stripeAccount: connectedAccountId,
        });
        const formattedAvailableFunds = formatAvailableFunds(balance.available);
        const formattedPendingFunds = formatPendingFunds(balance.pending);
        const formattedInstantAvailable = balance.instant_available != null ? formatInstantAvailableFunds(balance.instant_available) : "";
        const formattedConnectReserved = balance.connect_reserved != null ? formatConnectReservedFunds(balance.connect_reserved) : "";

        if (formattedAvailableFunds == "" && formattedPendingFunds == "" && formattedInstantAvailable == "" && formattedConnectReserved == "") {
            return [true, ""];
        }

        return [false, formattedAvailableFunds + formattedPendingFunds + formattedInstantAvailable + formattedConnectReserved];
    } catch (error) {
        errorMessage += handleStripeError("allBalancesZeroStripeConnectedAccount", error);
        throw new Error(errorMessage);
    }
};