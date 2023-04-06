import { Logging } from '@google-cloud/logging';
import { LogSeverity } from '@google-cloud/logging/build/src/entry';
import { GoogleCloudProvider } from './google_cloud_provider';

export class Logger {
    static LOG = new Logging({ projectId: GoogleCloudProvider.PROJECT });
    static CALL_SERVER = "call-server";

    static async log({ logName, message, severity, labels }: { logName: string, message: string, severity?: LogSeverity, labels?: Map<string, string> }): Promise<void> {
        const log = Logger.LOG.log(logName);
        const entry = log.entry({
            metadata: {
                severity: severity !== undefined ? severity : "INFO",
                labels: labels !== undefined ? Object.fromEntries(labels) : {}
            }, data: message,
        });
        await log.write(entry);
    }

    static logError({ logName, message, labels }: { logName: string, message: string, severity?: LogSeverity, labels?: Map<string, string> }): Promise<void> {
        return Logger.log({ logName: logName, message: message, severity: "ERROR", labels: labels });
    }
}