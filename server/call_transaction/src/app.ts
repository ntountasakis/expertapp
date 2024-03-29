import {Server, ServerCredentials} from "@grpc/grpc-js";
import * as grpc from "@grpc/grpc-js";
import * as protoLoader from "@grpc/proto-loader";
import * as admin from "firebase-admin";
import {ProtoGrpcType} from "./protos/call_transaction";
import {CallTransactionServer} from "./server/main/call_transaction_server";
import {applicationDefault} from "firebase-admin/app";
import {Logger} from "../../functions/src/shared/src/google_cloud/google_cloud_logger";
import {StripeProvider} from "../../functions/src/shared/src/stripe/stripe_provider";

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
        throw new Error("Cannot start server: IS_PROD is not defined");
      }
      if (process.env.STRIPE_PRIVATE_KEY_VERSION === undefined || process.env.STRIPE_PRIVATE_KEY_VERSION === null ||
        process.env.STRIPE_PRIVATE_KEY_VERSION.length === 0) {
        throw new Error("Cannot start server: STRIPE_PRIVATE_KEY_VERSION is not defined");
      }
      await StripeProvider.configureStripe(process.env.STRIPE_PRIVATE_KEY_VERSION);

      Logger.log({
        logName: Logger.CALL_SERVER, message: `gRPC:Server:${bindPort} isProd: ${process.env.IS_PROD}`,
        labels: new Map([["isProd", process.env.IS_PROD], ["port", bindPort.toString()]]),
      });

      const useEmulator = process.env.IS_PROD === "false";
      if (useEmulator) {
        const firestoreUrl = "host.docker.internal:9002";
        process.env["FIRESTORE_EMULATOR_HOST"] = firestoreUrl;
        Logger.log({
          logName: Logger.CALL_SERVER, message: `Configuring firestore to point to local emulator ${firestoreUrl}`,
        });
        admin.initializeApp();
      } else {
        admin.initializeApp({
          credential: applicationDefault(),
        });
      }
      server.start();
    });
