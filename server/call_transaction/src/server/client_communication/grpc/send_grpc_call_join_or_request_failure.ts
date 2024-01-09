import {Logger} from "../../../../../functions/src/shared/src/google_cloud/google_cloud_logger";
import {BaseCallState} from "../../../call_state/common/base_call_state";
import {ClientMessageSenderInterface} from "../../../message_sender/client_message_sender_interface";
import {ServerCallJoinOrRequestResponse} from "../../../protos/call_transaction_package/ServerCallJoinOrRequestResponse";

export async function sendGrpcCallJoinOrRequestFailure(
    errorMessage: string, clientMessageSender: ClientMessageSenderInterface, callState: BaseCallState): Promise<void> {
  Logger.logError({
    logName: "sendGrpcCallJoinOrRequestFailure", message: `Error: ${errorMessage} `,
  });
  const serverCallJoinOrRequestResponse: ServerCallJoinOrRequestResponse = {
    "success": false,
    "errorMessage": errorMessage,
  };
  clientMessageSender.sendCallJoinOrRequestResponse(serverCallJoinOrRequestResponse, callState);
}
