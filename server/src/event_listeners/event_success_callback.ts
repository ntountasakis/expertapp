import {BaseCallState} from "../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";

export interface EventSuccessCallback {
    (messageSender: ClientMessageSenderInterface, callState: BaseCallState): void;
}
