/* eslint-disable max-len */
import * as grpc from "@grpc/grpc-js";
import {sendToken} from "./fcm_token_sender";
import {CallMessage} from "./protos/call_transaction_package/CallMessage";
import {CallRequest} from "./protos/call_transaction_package/CallRequest";
import {CallTransactionHandlers} from "./protos/call_transaction_package/CallTransaction";

export const callTransactionServer: CallTransactionHandlers = {
  InitiateCall(call: grpc.ServerUnaryCall<CallRequest, CallMessage>,
      callback: grpc.sendUnaryData<CallMessage>) {
    console.log("initiate call called");
    if (call.request) {
      console.log(`(server) Got client message: ${call.request.userAuthToken}`);

      const testToken = "ephm2tBXR5iiurKerFuxOh:APA91bELYtYQctt6v76P2v5nx8IS3rm-RXXr-rwXe-hxPrWZV4quk-MY3jN8SjOkRnPIISzrQxNwSVTCIAv2KuBAfxzPEZJ3-ZfYvWb-1LN__xzc7YwRtbDpUw2BKc-vXenIwW1SJ2yz";
      sendToken(testToken);
    }
    callback(null, {
      ack: "Hello from the server",
    });
  },
};
