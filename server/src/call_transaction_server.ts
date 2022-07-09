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
  async InitiateCall(call: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>) {
    call.on("data", async (aClientMessage: ClientMessageContainer) => {
      if (aClientMessage.callJoinRequest != null) {
        const transactionId = aClientMessage.callJoinRequest.callTransactionId;
        const joinerId = aClientMessage.callJoinRequest.joinerUid;
        console.log(`Got call join request from joinerId: ${joinerId} with transaction id: ${transactionId}`);
        call.end();
        return;
      }
      const [paramsValid, paramsInvalidErrorMessage] = callInitiateRequestParamsValid(aClientMessage);
      if (!paramsValid) {
        sendCallRequestFailure(paramsInvalidErrorMessage, call);
        call.end();
        return;
      }

      const clientCallRequest = aClientMessage.callInitiateRequest;
      if (clientCallRequest == null) {
        throw new Error("Client call request shouldn't be null!");
      }

      console.log(`InitiateCall request begin. Caller Uid: ${clientCallRequest.callerUid} 
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

      // todo: named params
      sendCallJoinRequest(callTransactionResult.calledToken, request, callTransactionResult.callTransactionId);
      sendCallRequestSuccess(call);

      call.end();

      console.log(`InitiateCall request success. Caller Uid: ${clientCallRequest.callerUid} 
      Called Uid: ${clientCallRequest.calledUid}`);
    });
    call.on("error", (error: Error) => {
      console.log(`Error Initiate Call: ${error}`);
    });
    call.on("end", () => {
      console.log("End Initiate Call Stream");
    });
  },
};

function callInitiateRequestParamsValid(request: ClientMessageContainer): [success: boolean, errorMessage: string] {
  if (request == null) {
    return [false, "InitiateCall request object null"];
  }
  const clientInitiateRequest = request.callInitiateRequest;
  if (clientInitiateRequest == null) {
    return [false, "Unexpected messageType in ClientMessageContainer in Initiate Call"];
  }
  if (clientInitiateRequest.calledUid == null || clientInitiateRequest.calledUid.length == 0) {
    return [false, "InitiateCall Error: CalledUID empty or zero-length"];
  }
  if (clientInitiateRequest.callerUid == null || clientInitiateRequest.callerUid.length == 0) {
    return [false, "InitiateCall Error: CallerUID empty or zero-length"];
  }
  return [true, ""];
}
function sendCallRequestFailure(errorMessage: string,
    call: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>) {
  console.error(errorMessage);
  const serverCallRequestResponse: ServerCallRequestResponse = {
    "success": false,
    "errorMessage": errorMessage,
  };
  call.write(makeServerMessageContainer(serverCallRequestResponse));
}

function sendCallRequestSuccess(call: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>) {
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
