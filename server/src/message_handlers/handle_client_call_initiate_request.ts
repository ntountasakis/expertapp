import {CallTransctionRequestResult} from "../call_transaction_request_result";
import {createCallTransaction} from "../create_call_transaction";
import {sendCallJoinRequest} from "../firebase/fcm/fcm_token_sender";
import {CallJoinRequest} from "../firebase/fcm/messages/call_join_request";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallInitiateRequest} from "../protos/call_transaction_package/ClientCallInitiateRequest";
import {ServerCallRequestResponse} from "../protos/call_transaction_package/ServerCallRequestResponse";

export async function handleClientCallInitiateRequest(callInitiateRequest: ClientCallInitiateRequest,
    clientMessageSender: ClientMessageSenderInterface): Promise<void> {
  console.log(`InitiateCall request begin. Caller Uid: ${callInitiateRequest.callerUid} 
      Called Uid: ${callInitiateRequest.calledUid}`);

  const calledUid = callInitiateRequest.calledUid as string;
  const callerUid = callInitiateRequest.callerUid as string;
  const request = new CallJoinRequest({callerUid: callerUid, calledUid: calledUid});
  const callTransactionResult: CallTransctionRequestResult = await createCallTransaction({request: request});

  if (!callTransactionResult.success) {
    sendCallRequestFailure(`Unable to create call transaction. Error: ${callTransactionResult.errorMessage}`,
        clientMessageSender);
    return;
  }

  // todo: named params
  sendCallJoinRequest(callTransactionResult.calledToken, request, callTransactionResult.callTransactionId);
  sendCallRequestSuccess(clientMessageSender);
  return;
}

function sendCallRequestFailure(errorMessage: string,
    clientMessageSender: ClientMessageSenderInterface) {
  console.error(errorMessage);
  const serverCallRequestResponse: ServerCallRequestResponse = {
    "success": false,
    "errorMessage": errorMessage,
  };
  clientMessageSender.send(serverCallRequestResponse);
}

function sendCallRequestSuccess(clientMessageSender: ClientMessageSenderInterface) {
  const serverCallRequestResponse: ServerCallRequestResponse = {
    "success": true,
    "errorMessage": "",
  };
  clientMessageSender.send(serverCallRequestResponse);
}
