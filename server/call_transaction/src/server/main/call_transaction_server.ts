import * as grpc from "@grpc/grpc-js";
import {Logger} from "../../../../shared/src/google_cloud/google_cloud_logger";
import {CallManager} from "../../call_state/common/call_manager";
import {dispatchClientMessage} from "../../message_handlers/client_message_dispatcher";
import {GrpcClientMessageSender} from "../../message_sender/grpc_client_message_sender";
import {CallTransactionHandlers} from "../../protos/call_transaction_package/CallTransaction";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";

const callManager = new CallManager();

export class CallTransactionServer implements CallTransactionHandlers {
  [name: string]: grpc.UntypedHandleCall;

  async InitiateCall(call: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>): Promise<void> {
    const metadata = call.metadata.getMap();
    if (!isMetadataValid(metadata)) {
      call.emit("error", {code: grpc.status.INTERNAL, message: "Server is having technical difficulties"});
      call.end();
      return;
    }
    const userId = metadata["uid"] as string;
    const isCaller: boolean = (metadata["iscaller"] as string) === "true";
    Logger.log({
      logName: Logger.CALL_SERVER, message: `UserId: ${userId} initiate call`,
      labels: new Map([["userId", userId], ["isCaller", isCaller.toString()]]),
    });

    call.on("data", async (aClientMessage: ClientMessageContainer) => {
      const messageSender = new GrpcClientMessageSender(call);
      try {
        await dispatchClientMessage({
          clientMessage: aClientMessage, invalidMessageHandler: invalidMessageCallback,
          clientMessageSender: messageSender, callManager: callManager, callStream: call,
        });
      } catch (error) {
        Logger.logError({
          logName: Logger.CALL_SERVER, message: `Error dispatching client message: ${error}. Terminating connection to ${userId}`,
          labels: new Map([["userId", userId], ["isCaller", isCaller.toString()]]),
        });
        call.emit("error", {code: grpc.status.INTERNAL, message: error});
        call.end();
      }
    });
    call.on("error", (error: Error) => {
      Logger.logError({
        logName: Logger.CALL_SERVER, message: `Error Initiate Call: ${error}. Terminating connection to ${userId}`,
        labels: new Map([["userId", userId], ["isCaller", isCaller.toString()]]),
      });
      call.end();
    });
    call.on("end", async () => {
      Logger.log({
        logName: Logger.CALL_SERVER, message: "End Initiate Call Stream",
        labels: new Map([["userId", userId], ["isCaller", isCaller.toString()]]),
      });
      await disconnectClient({userId: userId});
      call.end();
    });
    call.on("cancelled", () => {
      Logger.log({
        logName: Logger.CALL_SERVER, message: `UserId: ${userId} cancelled call`,
        labels: new Map([["userId", userId], ["isCaller", isCaller.toString()]]),
      });
      call.end();
    });
  }
}

async function disconnectClient({userId}: { userId: string }) {
  await callManager.onClientDisconnect({userId: userId});
}

function isMetadataValid(metadata: { [key: string]: grpc.MetadataValue; }): boolean {
  const userId = metadata["uid"] as string;
  if (userId === undefined || userId.length === 0) {
    Logger.logError({
      logName: Logger.CALL_SERVER, message: "Cannot find metadata with Key: uid",
    });
    return false;
  }
  const isCaller = metadata["iscaller"] as string;
  if (isCaller === undefined || isCaller.length === 0 || (isCaller !== "true" && isCaller !== "false")) {
    Logger.logError({
      logName: Logger.CALL_SERVER, message: `Cannot find/parse metadata with Key: isCaller: ${isCaller}`,
    });
    return false;
  }
  return true;
}

function invalidMessageCallback(errorMessage: string): void {
  Logger.logError({
    logName: Logger.CALL_SERVER, message: `Invalid message: ${errorMessage}`,
  });
  throw new Error(errorMessage);
}
