// eslint-disable-next-line max-len
import {endCallTransactionClientInitiated, EndCallTransactionReturnType} from "../firebase/firestore/functions/end_call_transaction_client_initiated";
import {ClientMessageSenderInterface} from "../message_sender/client_message_sender_interface";
import {ClientCallTerminateRequest} from "../protos/call_transaction_package/ClientCallTerminateRequest";
// eslint-disable-next-line max-len
import {sendGrpcServerCallTerminatePaymentInitiate} from "../server/client_communication/grpc/send_grpc_server_call_terminate_payment_initiate";

export async function handleClientCallTerminateRequest(callTerminateRequest: ClientCallTerminateRequest,
    clientMessageSender: ClientMessageSenderInterface):
Promise<void> {
  // todo: use return values
  const endCallPromise: Promise<EndCallTransactionReturnType> =
    endCallTransactionClientInitiated({terminateRequest: callTerminateRequest});

  endCallPromise
      .catch((reason) => {
        console.error(`handleClientCallTerminateRequest exception: ${reason}`);
      })
      .then((response: void | EndCallTransactionReturnType) => {
          const [endCallPaymentIntentClientSecret, callerStripeCustomerId] = response;

      }


  // if (typeof endCallPromise === "string") {
  //   // todo: handle
  //   return;
  // }
  // const [endCallPaymentIntentClientSecret, callerStripeCustomerId] = endCallPromise;
  // sendGrpcServerCallTerminatePaymentInitiate({clientMessageSender: clientMessageSender,
  //   customerId: callerStripeCustomerId, clientSecret: endCallPaymentIntentClientSecret});
}
