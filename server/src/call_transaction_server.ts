/* eslint-disable max-len */
import * as grpc from "@grpc/grpc-js";
import {createCallTransaction} from "./create_call_transaction";
import {sendCallJoinRequest} from "./firebase/fcm/fcm_token_sender";
import {CallJoinRequest} from "./firebase/fcm/messages/call_join_request";
import {lookupUserToken} from "./firebase/firestore/lookup_user_token";
import {CallMessage} from "./protos/call_transaction_package/CallMessage";
import {CallRequest} from "./protos/call_transaction_package/CallRequest";
import {CallTransactionHandlers} from "./protos/call_transaction_package/CallTransaction";

export const callTransactionServer: CallTransactionHandlers = {
  async InitiateCall(call: grpc.ServerUnaryCall<CallRequest, CallMessage>,
      callback: grpc.sendUnaryData<CallMessage>) {
    if (call.request) {
      console.log("Call Request");
      console.log(`Caller Uid: ${call.request.calledUid} Called Uid: ${call.request.calledUid}`);

      if (call.request.calledUid !== undefined && call.request.callerUid !== undefined) {
        const calledUserToken = await lookupUserToken(call.request.calledUid);

        if (calledUserToken.length !== 0) {
          console.log(`Send to token ${calledUserToken}`);

          const request = new CallJoinRequest({callerUid: call.request.callerUid, calledUid: call.request.calledUid});

          const callTransactionCreateSuccess: boolean = await createCallTransaction(request);

          if (!callTransactionCreateSuccess) {
            console.error("Unable to create call transaction");
          } else {
            sendCallJoinRequest(calledUserToken, request);
          }
        } else {
          console.error(`Erroring out of call request, cannot find test token for ${call.request.calledUid}`);
        }
      } else {
        console.error("Called/Caller Uid undefined in call rquest");
      }
    }

    callback(null, {
      ack: "Hello from the server",
    });
  },
};
