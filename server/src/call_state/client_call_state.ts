import {CallTransctionRequestResult} from "../call_transaction_request_result";
import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";

export class ClientCallState {
    callJoinRequest: CallJoinRequest;
    transaction: CallTransctionRequestResult;

    constructor(callJoinRequest: CallJoinRequest, transaction: CallTransctionRequestResult) {
      this.callJoinRequest = callJoinRequest;
      this.transaction = transaction;
    }
}
