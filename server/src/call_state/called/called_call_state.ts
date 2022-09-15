import {BaseCallState} from "../common/base_call_state";
import {CallOnDisconnectInterface} from "../functions/call_on_disconnect_interface";

export class CalledCallState extends BaseCallState {
  constructor({transactionId, onDisconnect}:
    {transactionId: string, onDisconnect: CallOnDisconnectInterface}) {
    super({transactionId: transactionId, onDisconnect: onDisconnect});
  }
}
