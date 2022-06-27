import {Server, ServerCredentials} from "@grpc/grpc-js";

import * as grpc from "@grpc/grpc-js";
import * as protoLoader from "@grpc/proto-loader";
import * as admin from "firebase-admin";
import {ProtoGrpcType} from "./protos/call_transaction";
import {callTransactionServer} from "./call_transaction_server";

function getServer(): Server {
  const packageDefinition = protoLoader.loadSync("../protos/call_transaction.proto");
  const proto = grpc.loadPackageDefinition(
      packageDefinition
  ) as unknown as ProtoGrpcType;
  const server = new Server();
  server.addService(proto.call_transaction_package.CallTransaction.service, callTransactionServer);
  return server;
}

const server = getServer();

server.bindAsync(`0.0.0.0:${process.env.PORT}`, ServerCredentials.createInsecure(),
    (err: Error | null, bindPort: number) => {
      if (err) {
        console.error(`Cannot start server: ${err.message}`);
        throw err;
      }

      console.log(`gRPC:Server:${bindPort}`, new Date().toLocaleString());

      const useEmulator = true;
      if (useEmulator) {
        const firestoreUrl = "host.docker.internal:9002";
        console.log(`Configuring firestore to point to local emulator ${firestoreUrl}`);
        process.env["FIRESTORE_EMULATOR_HOST"] = firestoreUrl;
      }
      admin.initializeApp();
      server.start();
    });
