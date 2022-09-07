import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";
import {CallTransaction} from "../firebase/firestore/models/call_transaction";

export class ClientCallState {
    callJoinRequest: CallJoinRequest;
    transaction: CallTransaction;

    constructor(callJoinRequest: CallJoinRequest, transaction: CallTransaction) {
      this.callJoinRequest = callJoinRequest;
      this.transaction = transaction;
    }
}
