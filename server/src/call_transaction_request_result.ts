export class CallTransctionRequestResult {
    _success = false;
    _errorMessage = "";
    _calledFcmToken = "";
    _callTransactionId = "";
    _agoraChannelName = "";
    _stripeCallerClientSecret = "";
    _stripeCallerCustomerId = "";

    set success(success: boolean) {
      this._success = success;
    }

    get success(): boolean {
      return this._success;
    }

    set errorMessage(message: string) {
      this._errorMessage = message;
    }

    get errorMessage(): string {
      return this._errorMessage;
    }

    set calledFcmToken(token: string) {
      this._calledFcmToken = token;
    }

    get calledFcmToken(): string {
      return this._calledFcmToken;
    }

    set callTransactionId(transactionId: string) {
      this._callTransactionId = transactionId;
    }

    get callTransactionId(): string {
      return this._callTransactionId;
    }

    set agoraChannelName(agoraChannelName: string) {
      this._agoraChannelName = agoraChannelName;
    }

    get agoraChannelName(): string {
      return this._agoraChannelName;
    }

    set stripeCallerClientSecret(secret: string) {
      this._stripeCallerClientSecret = secret;
    }

    get stripeCallerClientSecret(): string {
      return this._stripeCallerClientSecret;
    }

    set stripeCallerCustomerId(customerId: string) {
      this._stripeCallerCustomerId = customerId;
    }

    get stripeCallerCustomerId(): string {
      return this._stripeCallerCustomerId;
    }
}
