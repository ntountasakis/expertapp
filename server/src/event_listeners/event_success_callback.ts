import {ClientCallState} from "../call_state/client_call_state";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";

export interface EventSuccessCallback {
    (messageSender: ClientMessageSenderInterface, clientCallState: ClientCallState): void;
}
