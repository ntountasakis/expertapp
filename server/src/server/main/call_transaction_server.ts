import * as grpc from "@grpc/grpc-js";
import {ClientCallManager} from "../../call_state/client_call_manager";
import {dispatchClientMessage} from "../../message_handlers/client_message_dispatcher";
import {GrpcClientMessageSender} from "../../message_sender/grpc_client_message_sender";
import {CallTransactionHandlers} from "../../protos/call_transaction_package/CallTransaction";
import {ClientMessageContainer} from "../../protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "../../protos/call_transaction_package/ServerMessageContainer";

const clientCallManager = new ClientCallManager();

export class CallTransactionServer implements CallTransactionHandlers {
  [name: string]: grpc.UntypedHandleCall;

  async InitiateCall(call: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>): Promise<void> {
    const userId = call.metadata.getMap()["uid"] as string;
    if (userId === undefined) {
      console.error("Cannot find metadata with Key: uid");
      call.end();
      return;
    }
    console.log(`UserId: ${userId} initiate call`);

    call.on("data", async (aClientMessage: ClientMessageContainer) => {
      const messageSender = new GrpcClientMessageSender(call);
      dispatchClientMessage({clientMessage: aClientMessage, invalidMessageHandler: invalidMessageCallback,
        clientMessageSender: messageSender, clientCallManager: clientCallManager});
    });
    call.on("error", (error: Error) => {
      console.log(`Error Initiate Call: ${error}`);
    });
    call.on("end", () => {
      console.log("End Initiate Call Stream");
      call.end();
    });
    call.on("cancelled", () => {
      console.log(`UserId: ${userId} cancelled call`);
      clientCallManager.clearCallState({userId: userId});
    });
  }
}


function invalidMessageCallback(errorMessage: string): void {
  // todo: disonnect client
  console.error(errorMessage);
}
