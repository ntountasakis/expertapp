import * as grpc from "@grpc/grpc-js";
import {CallTransctionRequestResult} from "./call_transaction_request_result";
import {createCallTransaction} from "./create_call_transaction";
import {sendCallJoinRequest} from "./firebase/fcm/fcm_token_sender";
import {CallJoinRequest} from "./firebase/fcm/messages/call_join_request";
import {CallMessage} from "./protos/call_transaction_package/CallMessage";
import {CallRequest} from "./protos/call_transaction_package/CallRequest";
import {CallTransactionHandlers} from "./protos/call_transaction_package/CallTransaction";

export const callTransactionServer: CallTransactionHandlers = {
  async InitiateCall(call: grpc.ServerUnaryCall<CallRequest, CallMessage>, callback: grpc.sendUnaryData<CallMessage>) {
    const [paramsValid, paramsInvalidErrorMessage] = callRequestParamsValid(call.request);
    if (!paramsValid) {
      sendCallRequestFailure(paramsInvalidErrorMessage, callback);
      return;
    }

    console.log(`InitiateCall request begin. Caller Uid: ${call.request.calledUid} 
      Called Uid: ${call.request.calledUid}`);

    const calledUid = call.request.calledUid as string;
    const callerUid = call.request.callerUid as string;
    const request = new CallJoinRequest({callerUid: callerUid, calledUid: calledUid});
    const callTransactionResult: CallTransctionRequestResult = await createCallTransaction({request: request});

    if (!callTransactionResult.success) {
      sendCallRequestFailure(`Unable to create call transaction. Error: ${callTransactionResult.errorMessage}`,
          callback);
      return;
    }

    sendCallJoinRequest(callTransactionResult.calledToken, request);
    sendCallRequestSuccess(callback);

    console.log(`InitiateCall request success. Caller Uid: ${call.request.calledUid} 
      Called Uid: ${call.request.calledUid}`);
  },
};

function callRequestParamsValid(request: CallRequest): [success: boolean, errorMessage: string] {
  if (request == null) {
    return [false, "InitiateCall request object null"];
  }
  if (request.calledUid == null || request.calledUid.length == 0) {
    return [false, "InitiateCall Error: CalledUID empty or zero-length"];
  }
  if (request.callerUid == null || request.callerUid.length == 0) {
    return [false, "InitiateCall Error: CallerUID empty or zero-length"];
  }
  return [true, ""];
}

function sendCallRequestFailure(errorMessage: string, callback: grpc.sendUnaryData<CallMessage>) {
  console.error(errorMessage);
  callback(null, {
    "success": false,
    "errorMessage": errorMessage,
  });
}

function sendCallRequestSuccess(callback: grpc.sendUnaryData<CallMessage>) {
  callback(null, {
    "success": true,
    "errorMessage": "",
  });
}

