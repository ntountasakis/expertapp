export interface ClientCallOnDisconnectInterface {
    ({transactionId}: {transactionId: string}): void;
}
