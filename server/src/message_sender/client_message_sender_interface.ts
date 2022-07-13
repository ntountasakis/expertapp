import {ServerAgoraCredentials} from "../protos/call_transaction_package/ServerAgoraCredentials";
import {ServerCallRequestResponse} from "../protos/call_transaction_package/ServerCallRequestResponse";

export abstract class ClientMessageSenderInterface {
    abstract sendCallRequestResponse(callRequestResponse: ServerCallRequestResponse): void;
    abstract sendCallAgoraCredentials(callAgoraCredentials: ServerAgoraCredentials): void;
}
