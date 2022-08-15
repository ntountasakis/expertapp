type VoidCallback = () => void;

export class CallManager {
  _paymentStatusUnsubFns = new Map<string, VoidCallback>();

  registerPaymentStatusUnsubscribeFn(paymentStatusId: string, unsubscribeFn: () => void): void {
    this._paymentStatusUnsubFns.set(paymentStatusId, unsubscribeFn);
  }
}
