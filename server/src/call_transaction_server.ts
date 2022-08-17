import * as grpc from "@grpc/grpc-js";
import {EventListenerManager} from "./event_listeners/event_listener_manager";
import {dispatchClientMessage} from "./message_handlers/client_message_dispatcher";
import {GrpcClientMessageSender} from "./message_sender/grpc_client_message_sender";
import {CallTransactionHandlers} from "./protos/call_transaction_package/CallTransaction";
import {ClientMessageContainer} from "./protos/call_transaction_package/ClientMessageContainer";
import {ServerMessageContainer} from "./protos/call_transaction_package/ServerMessageContainer";

const eventListenerManager = new EventListenerManager();

export class CallTransactionServer implements CallTransactionHandlers {
  [name: string]: grpc.UntypedHandleCall;

  async InitiateCall(call: grpc.ServerDuplexStream<ClientMessageContainer, ServerMessageContainer>): Promise<void> {
    call.on("data", async (aClientMessage: ClientMessageContainer) => {
      const messageSender = new GrpcClientMessageSender(call);
      dispatchClientMessage({clientMessage: aClientMessage, invalidMessageHandler: invalidMessageCallback,
        clientMessageSender: messageSender, eventListenerManager: eventListenerManager});
    });
    call.on("error", (error: Error) => {
      console.log(`Error Initiate Call: ${error}`);
    });
    call.on("end", () => {
      console.log("End Initiate Call Stream");
      call.end();
    });
  }
}


function invalidMessageCallback(errorMessage: string): void {
  // todo: disonnect client
  console.error(errorMessage);
}
