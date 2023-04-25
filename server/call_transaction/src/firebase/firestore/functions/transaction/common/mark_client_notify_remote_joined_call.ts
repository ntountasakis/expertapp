import * as admin from "firebase-admin";
import {ClientNotifyRemoteJoinedCall} from "../../../../../protos/call_transaction_package/ClientNotifyRemoteJoinedCall";
import {CallTransaction} from "../../../../../../../shared/src/firebase/firestore/models/call_transaction";
import {getCallTransactionDocument, getCallTransactionDocumentRef} from "../../../../../../../shared/src/firebase/firestore/document_fetchers/fetchers";

export const markClientNotifyRemoteJoinedCall = async ({notify, transactionId, isCaller}:
    { notify: ClientNotifyRemoteJoinedCall, transactionId: string, isCaller: boolean }):
  Promise<void> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    const callTransaction: CallTransaction = await getCallTransactionDocument(
        {transaction: transaction, transactionId: transactionId});


    if (!callTransaction.calledHasJoined) {
      throw new Error(`CallTransaction ${transactionId} has not been joined by called. Cannot mark client notify remote joined call`);
    }
    if (isCaller) {
      if (notify.clientUid != callTransaction.callerUid || notify.remoteUid != callTransaction.calledUid) {
        throw new Error(`ClientNotifyRemoteJoinedCall invalid. transactionId: ${transactionId} notifyClientUid: ${notify.clientUid} \
        notifyRemoteUid: ${notify.remoteUid}`);
      }
      transaction.update(getCallTransactionDocumentRef({transactionId: transactionId}), {
        "callerNotifiedCalledJoined": true,
      });
    } else {
      if (notify.clientUid != callTransaction.calledUid || notify.remoteUid != callTransaction.callerUid) {
        throw new Error(`ClientNotifyRemoteJoinedCall invalid. transactionId: ${transactionId} notifyClientUid: ${notify.clientUid} \
        notifyRemoteUid: ${notify.remoteUid}`);
      }
      transaction.update(getCallTransactionDocumentRef({transactionId: transactionId}), {
        "calledNotifiedCallerJoined": true,
      });
    }
  });
};
