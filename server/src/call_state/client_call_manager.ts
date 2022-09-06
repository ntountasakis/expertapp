import {CallTransctionRequestResult} from "../call_transaction_request_result";
import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";
import {ClientCallState} from "./client_call_state";

export class ClientCallManager {
    clientCallStates = new Map<string, ClientCallState>();

    createNewCallState(callJoinRequest: CallJoinRequest,
        callTransactionRequestResult: CallTransctionRequestResult): ClientCallState {
      const callState = new ClientCallState(callJoinRequest, callTransactionRequestResult);
      this.clientCallStates.set(callTransactionRequestResult._callTransactionId, callState);
      return callState;
    }
}
