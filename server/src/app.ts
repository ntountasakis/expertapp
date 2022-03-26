import { Logging } from '@google-cloud/logging';
import express from 'express';

const projectId = 'expert-app-backend'; // Your Google Cloud Platform project ID
const logName = 'expert-app-server-log'; // The name of the log to write to

async function log(text: string) {
  // Creates a client
  const logging = new Logging({projectId});

  // Selects the log to write to
  const log = logging.log(logName);

  // The metadata associated with the entry
  const metadata = {
    resource: {type: 'global'},
    // See: https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#logseverity
    severity: 'INFO',
  };

  // Prepares a log entry
  const entry = log.entry(metadata, text);

  async function writeLog() {
    // Writes the log entry
    await log.write(entry);
  }
  writeLog();
}

const app = express();

app.get('/', async (req, res) => {
  console.log('Sending hello world');
  res.send('Hello World2!')
  await log('Logged hello world in google logging');
})

app.listen(process.env.PORT, () => {
  console.log(`server running on port ${process.env.PORT}`);
});
