import { Server, ServerCredentials } from "@grpc/grpc-js";

import * as grpc from "@grpc/grpc-js";
import * as protoLoader from "@grpc/proto-loader";
import * as admin from "firebase-admin";
import { ProtoGrpcType } from "./protos/call_transaction";
import { CallTransactionServer } from "./server/main/call_transaction_server";
import { StripeProvider } from "../../shared/src/stripe/stripe_provider";

function getServer(): Server {
  const packageDefinition = protoLoader.loadSync("../protos/call_transaction.proto");
  const proto = grpc.loadPackageDefinition(
    packageDefinition
  ) as unknown as ProtoGrpcType;
  const server = new Server();
  server.addService(proto.call_transaction_package.CallTransaction.service, new CallTransactionServer());
  return server;
}

const server = getServer();


server.bindAsync(`0.0.0.0:${process.env.PORT}`, ServerCredentials.createInsecure(),
  async (err: Error | null, bindPort: number) => {
    if (err) {
      console.error(`Cannot start server: ${err.message}`);
      throw err;
    }

    if (process.env.IS_PROD === undefined || process.env.IS_PROD === null || process.env.IS_PROD.length === 0) {
      throw new Error(`Cannot start server: IS_PROD is not defined`);
    }
    if (process.env.STRIPE_PRIVATE_KEY_VERSION === undefined || process.env.STRIPE_PRIVATE_KEY_VERSION === null || process.env.STRIPE_PRIVATE_KEY_VERSION.length === 0) {
      throw new Error(`Cannot start server: STRIPE_PRIVATE_KEY_VERSION is not defined`);
    }
    await StripeProvider.configureStripe(process.env.STRIPE_PRIVATE_KEY_VERSION);

    console.log(`gRPC:Server:${bindPort} isProd: ${process.env.IS_PROD}`, new Date().toLocaleString());

    const useEmulator = process.env.IS_PROD === "false";
    if (useEmulator) {
      const firestoreUrl = "host.docker.internal:9002";
      console.log(`Configuring firestore to point to local emulator ${firestoreUrl}`);
      process.env["FIRESTORE_EMULATOR_HOST"] = firestoreUrl;
    }
    admin.initializeApp();
    server.start();
  });
