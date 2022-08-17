import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";

export interface EventSuccessCallback {
    (messageSender: ClientMessageSenderInterface): void;
}
