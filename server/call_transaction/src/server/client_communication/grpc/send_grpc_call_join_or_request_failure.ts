import { Logger } from "../../../../../shared/src/google_cloud/google_cloud_logger";
import { ClientMessageSenderInterface } from "../../../message_sender/client_message_sender_interface";
import { ServerCallJoinOrRequestResponse } from "../../../protos/call_transaction_package/ServerCallJoinOrRequestResponse";

export async function sendGrpcCallJoinOrRequestFailure(
  errorMessage: string, clientMessageSender: ClientMessageSenderInterface): Promise<void> {
  Logger.logError({
    logName: "sendGrpcCallJoinOrRequestFailure", message: `Error: ${errorMessage} `,
  });
  const serverCallJoinOrRequestResponse: ServerCallJoinOrRequestResponse = {
    "success": false,
    "errorMessage": errorMessage,
  };
  clientMessageSender.sendCallJoinOrRequestResponse(serverCallJoinOrRequestResponse);
}
