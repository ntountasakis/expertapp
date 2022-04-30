import { Logging } from '@google-cloud/logging';
import express from 'express';
import { Server, ServerCredentials } from '@grpc/grpc-js';

import * as grpc from '@grpc/grpc-js'
import * as protoLoader from '@grpc/proto-loader'
import { ProtoGrpcType } from './protos/call_transaction';
import { callTransactionServer } from './call_transaction_server';

// const projectId = 'expert-app-backend'; // Your Google Cloud Platform project ID
// const logName = 'expert-app-server-log'; // The name of the log to write to

function getServer(): grpc.Server {
  const packageDefinition = protoLoader.loadSync('../protos/call_transaction.proto');
  const proto = grpc.loadPackageDefinition(
    packageDefinition
  ) as unknown as ProtoGrpcType;
  const server = new grpc.Server();
  server.addService(proto.call_transaction_package.CallTransaction.service, callTransactionServer);
  return server;
}

const server = getServer();

server.bindAsync(`0.0.0.0:${process.env.PORT}`, ServerCredentials.createInsecure(), (err: Error | null, bindPort: number) => {
  if (err) {
    throw err;
  }

  console.log(`gRPC:Server:${bindPort}`, new Date().toLocaleString());
  server.start();
});

// const app = express();
// app.get('/', async (req, res) => {
//   console.log('Sending hello world');
//   res.send('Hello World2!')
//   await log('Logged hello world in google logging');
// })

// app.listen(process.env.PORT, () => {
//   console.log(`server running on port ${process.env.PORT}`);
// });

// async function log(text: string) {
//   // Creates a client
//   const logging = new Logging({projectId});

//   // Selects the log to write to
//   const log = logging.log(logName);

//   // The metadata associated with the entry
//   const metadata = {
//     resource: {type: 'global'},
//     // See: https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#logseverity
//     severity: 'INFO',
//   };

//   // Prepares a log entry
//   const entry = log.entry(metadata, text);

//   async function writeLog() {
//     // Writes the log entry
//     await log.write(entry);
//   }
//   writeLog();
// }