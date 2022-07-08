import * as grpc from "@grpc/grpc-js";
import {CallTransctionRequestResult} from "./call_transaction_request_result";
import {createCallTransaction} from "./create_call_transaction";
import {sendCallJoinRequest} from "./firebase/fcm/fcm_token_sender";
import {CallJoinRequest} from "./firebase/fcm/messages/call_join_request";
import {CallTransactionHandlers} from "./protos/call_transaction_package/CallTransaction";
import {ClientMessageContainer} from "./protos/call_transaction_package/ClientMessageContainer";
import {ServerCallRequestResponse} from "./protos/call_transaction_package/ServerCallRequestResponse";
import {ServerMessageContainer} from "./protos/call_transaction_package/ServerMessageContainer";

export const callTransactionServer: CallTransactionHandlers = {
  async InitiateCall(call: grpc.ServerWritableStream<ClientMessageContainer, ServerMessageContainer>) {
    const [paramsValid, paramsInvalidErrorMessage] = callRequestParamsValid(call.request);
    if (!paramsValid) {
      sendCallRequestFailure(paramsInvalidErrorMessage, call);
      call.end();
      return;
    }

    const clientCallRequest = call.request.callRequest;
    if (clientCallRequest == null) {
      throw new Error("Client call request shouldn't be null!");
    }

    console.log(`InitiateCall request begin. Caller Uid: ${clientCallRequest.calledUid} 
      Called Uid: ${clientCallRequest.calledUid}`);

    const calledUid = clientCallRequest.calledUid as string;
    const callerUid = clientCallRequest.callerUid as string;
    const request = new CallJoinRequest({callerUid: callerUid, calledUid: calledUid});
    const callTransactionResult: CallTransctionRequestResult = await createCallTransaction({request: request});

    if (!callTransactionResult.success) {
      sendCallRequestFailure(`Unable to create call transaction. Error: ${callTransactionResult.errorMessage}`,
          call);
      return;
    }

    sendCallJoinRequest(callTransactionResult.calledToken, request);
    sendCallRequestSuccess(call);

    call.end();

    console.log(`InitiateCall request success. Caller Uid: ${clientCallRequest.calledUid} 
      Called Uid: ${clientCallRequest.calledUid}`);
  },
};

function callRequestParamsValid(request: ClientMessageContainer): [success: boolean, errorMessage: string] {
  if (request == null) {
    return [false, "InitiateCall request object null"];
  }
  const clientCallRequest = request.callRequest;
  if (clientCallRequest == null) {
    return [false, "Unexpected messageType in ClientMessageContainer in Initiate Call"];
  }
  if (clientCallRequest.calledUid == null || clientCallRequest.calledUid.length == 0) {
    return [false, "InitiateCall Error: CalledUID empty or zero-length"];
  }
  if (clientCallRequest.callerUid == null || clientCallRequest.callerUid.length == 0) {
    return [false, "InitiateCall Error: CallerUID empty or zero-length"];
  }
  return [true, ""];
}
function sendCallRequestFailure(errorMessage: string,
    call: grpc.ServerWritableStream<ClientMessageContainer, ServerMessageContainer>) {
  console.error(errorMessage);
  const serverCallRequestResponse: ServerCallRequestResponse = {
    "success": false,
    "errorMessage": errorMessage,
  };
  call.write(makeServerMessageContainer(serverCallRequestResponse));
}

function sendCallRequestSuccess(call: grpc.ServerWritableStream<ClientMessageContainer, ServerMessageContainer>) {
  const serverCallRequestResponse: ServerCallRequestResponse = {
    "success": true,
    "errorMessage": "",
  };

  call.write(makeServerMessageContainer(serverCallRequestResponse));
}

function makeServerMessageContainer(serverCallRequestResponse: ServerCallRequestResponse): ServerMessageContainer {
  return {
    "ServerCallRequestResponse": serverCallRequestResponse,
    "messageWrapper": "ServerCallRequestResponse",
  };
}
