import {ClientMessageSenderInterface} from "../../message_sender/client_message_sender_interface";
import {BaseCallState} from "../common/base_call_state";

export interface CallOnDisconnectInterface {
    ({transactionId, clientMessageSender, callState}:
        {transactionId: string, clientMessageSender: ClientMessageSenderInterface, callState: BaseCallState,
        clientRequested: boolean}):
        Promise<void>;
}
