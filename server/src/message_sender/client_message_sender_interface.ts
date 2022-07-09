import {ServerCallRequestResponse} from "../protos/call_transaction_package/ServerCallRequestResponse";

export abstract class ClientMessageSenderInterface {
    abstract send(callRequestResponse: ServerCallRequestResponse): void;
}
