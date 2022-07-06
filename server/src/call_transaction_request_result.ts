export class CallTransctionRequestResult {
    _success = false;
    _errorMessage = "";
    _calledToken = "";

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

    set calledToken(token: string) {
      this._calledToken = token;
    }

    get calledToken(): string {
      return this._calledToken;
    }
}
