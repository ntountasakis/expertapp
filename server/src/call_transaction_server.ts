/* eslint-disable max-len */
import * as grpc from "@grpc/grpc-js";
import {sendToken} from "./fcm_token_sender";
import {lookupUserToken} from "./firebase/token_util";
import {CallMessage} from "./protos/call_transaction_package/CallMessage";
import {CallRequest} from "./protos/call_transaction_package/CallRequest";
import {CallTransactionHandlers} from "./protos/call_transaction_package/CallTransaction";

export const callTransactionServer: CallTransactionHandlers = {
  async InitiateCall(call: grpc.ServerUnaryCall<CallRequest, CallMessage>,
      callback: grpc.sendUnaryData<CallMessage>) {
    if (call.request) {
      console.log("Call Request");
      console.log(`Caller Uid: ${call.request.calledUid} Called Uid: ${call.request.calledUid}`);

      if (call.request.calledUid !== undefined) {
        const calledUserToken = await lookupUserToken(call.request.calledUid);

        if (calledUserToken.length !== 0) {
          console.log(`Send to token ${calledUserToken}`);
          sendToken(calledUserToken);
        } else {
          console.error(`Erroring out of call request, cannot find test token for ${call.request.calledUid}`);
        }
      } else {
        console.error("Called Uid undefined in call rquest");
      }
    }
    callback(null, {
      ack: "Hello from the server",
    });
  },
};
