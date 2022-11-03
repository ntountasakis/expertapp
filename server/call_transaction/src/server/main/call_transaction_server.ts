import * as grpc from "@grpc/grpc-js";
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
      call.end();
      return;
    }
    const userId = metadata["uid"] as string;
    const isCaller: boolean = (metadata["iscaller"] as string) === "true";
    console.log(`UserId: ${userId} initiate call`);

    call.on("data", async (aClientMessage: ClientMessageContainer) => {
      const messageSender = new GrpcClientMessageSender(call);
      try {
        dispatchClientMessage({clientMessage: aClientMessage, invalidMessageHandler: invalidMessageCallback,
          clientMessageSender: messageSender, callManager: callManager});
      } catch (error) {
        console.error(`Error dispatching client message: ${error}. Terminating connection to ${userId}`);
        call.end();
      }
    });
    call.on("error", (error: Error) => {
      console.log(`Error Initiate Call: ${error}`);
    });
    call.on("end", () => {
      console.log("End Initiate Call Stream");
      call.end();
    });
    call.on("cancelled", () => {
      console.log(`UserId: ${userId} cancelled call. IsCaller: ${isCaller}`);
      callManager.onClientDisconnect({userId: userId});
    });
  }
}

function isMetadataValid(metadata: { [key: string]: grpc.MetadataValue; }): boolean {
  const userId = metadata["uid"] as string;
  if (userId === undefined || userId.length === 0) {
    console.error("Cannot find metadata with Key: uid");
    return false;
  }
  const isCaller = metadata["iscaller"] as string;
  if (isCaller === undefined || isCaller.length === 0 || (isCaller !== "true" && isCaller !== "false")) {
    console.error(`Cannot find/parse metadata with Key: iscaller: ${isCaller}`);
    return false;
  }
  return true;
}

function invalidMessageCallback(errorMessage: string): void {
  // todo: disonnect client
  console.error(errorMessage);
}
