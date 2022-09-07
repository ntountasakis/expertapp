import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";
import {CallTransaction} from "../firebase/firestore/models/call_transaction";
import {ClientCallState} from "./client_call_state";

export class ClientCallManager {
    clientCallStates = new Map<string, ClientCallState>();

    createNewCallState(callJoinRequest: CallJoinRequest,
        callTransactionRequestResult: CallTransaction): ClientCallState {
      const callState = new ClientCallState(callJoinRequest, callTransactionRequestResult);
      this.clientCallStates.set(callTransactionRequestResult.callTransactionId, callState);
      return callState;
    }
}
