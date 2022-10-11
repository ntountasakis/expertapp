import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";
import {ExpertRate} from "../../../../../../../shared/firebase/firestore/models/expert_rate";
import {FcmToken} from "../../../../../../../shared/firebase/firestore/models/fcm_token";
import {CallJoinRequest} from "../../../../../../../shared/firebase/fcm/messages/call_join_request";
import {createPaymentStatus} from "../../../../../../../shared/firebase/firestore/functions/create_payment_status";
import {createCallTransactionDocument} from "../../../../../../../shared/firebase/firestore/functions/create_call_transaction_document";
import {getExpertRateDocument, getFcmTokenDocument} from "../../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import {CallTransaction} from "../../../../../../../shared/firebase/firestore/models/call_transaction";

export const createCallTransaction = async ({request}: {request: CallJoinRequest}): Promise<CallTransaction> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    if (request.calledUid == null || request.calledUid == null) {
      const errorMessage = `Invalid Call Transaction Request, either ids are null.
      CalledUid: ${request.calledUid} CallerUid: ${request.callerUid}`;
      throw new Error(errorMessage);
    }
    const expertRate: ExpertRate = await getExpertRateDocument(
        {transaction: transaction, expertUid: request.calledUid});
    const calledUserFcmToken: FcmToken = await getFcmTokenDocument({transaction: transaction, uid: request.calledUid});

    const transactionId = uuidv4();
    const paymentStatusId = uuidv4();
    const transferGroup = uuidv4();
    createPaymentStatus({transaction: transaction, uid: request.callerUid,
      paymentStatusId: paymentStatusId, transferGroup: transferGroup,
      costInCents: expertRate.centsCallStart});
    return createCallTransactionDocument({transaction: transaction, transactionId: transactionId,
      callerUid: request.callerUid, calledUid: request.calledUid, calledUserFcmToken: calledUserFcmToken,
      expertRate: expertRate, transferGroup: transferGroup, callRequestTimeUtcMs: Date.now(),
      agoraChannelName: uuidv4(), paymentStatusId: paymentStatusId});
  });
};
