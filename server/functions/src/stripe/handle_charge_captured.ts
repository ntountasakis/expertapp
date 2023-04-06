import * as admin from "firebase-admin";
import { getCallTransactionDocument, getPaymentStatusDocumentTransaction, getPrivateUserDocument } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { updatePaymentStatus } from "../../../shared/src/firebase/firestore/functions/update_payment_status";
import { CallTransaction } from "../../../shared/src/firebase/firestore/models/call_transaction";
import { PaymentStatus, PaymentStatusStates } from "../../../shared/src/firebase/firestore/models/payment_status";
import { PrivateUserInfo } from "../../../shared/src/firebase/firestore/models/private_user_info";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";
import createStripePaymentTransfer from "../../../shared/src/stripe/payment_transfer_creator";

export async function handleChargeCaptured(payload: any): Promise<void> {
  //   const livemode: boolean = payload.livemode;
  const amountCaptured: number = payload.amount_captured;
  const paymentStatusId: string = payload.metadata.payment_status_id;
  const callerUid: string = payload.metadata.caller_uid;
  const calledUid: string = payload.metadata.called_uid;
  const callTransactionId: string = payload.metadata.call_transaction_id;

  if (paymentStatusId == undefined) {
    Logger.logError({
      logName: "handleChargeCaptured", message: `Cannot handle PaymentIntentAmountCapturableUpdated. PaymentId undefined`,
    });
    return;
  }
  if (callerUid == undefined) {
    Logger.logError({
      logName: "handleChargeCaptured", message: `Cannot handle PaymentIntentAmountCapturableUpdated. Uid undefined`,
    });
    return;
  }

  const [paymentStatus, calledUserInfo, callTransaction] =
    await updatePaymentStateChargeCaptured({
      paymentStatusId: paymentStatusId, amountCaptured: amountCaptured, calledUid: calledUid,
      callTransactionId: callTransactionId
    });

  const transferId: string = await createStripePaymentTransfer({
    connectedAccountId: calledUserInfo.stripeConnectedId,
    amountToTransferInCents: callTransaction.earnedTotalCents, transferGroup: paymentStatus.transferGroup,
    sourceChargeId: paymentStatus.chargeId
  });

  Logger.log({
    logName: "handleChargeCaptured", message: `Transferred ${amountCaptured} cents with tranfser id: ${transferId} to calledUid: ${calledUid} connectedAccountId: ${calledUserInfo.stripeConnectedId}`,
    labels: new Map([["expertId", calledUid], ["userId", callerUid], ["callTransactionId", callTransactionId]]),
  });
}

async function updatePaymentStateChargeCaptured({ paymentStatusId, amountCaptured, calledUid, callTransactionId }:
  { paymentStatusId: string, amountCaptured: number, calledUid: string, callTransactionId: string }): Promise<[PaymentStatus, PrivateUserInfo, CallTransaction]> {
  try {
    return await admin.firestore().runTransaction(async (transaction) => {
      const paymentStatus: PaymentStatus = await getPaymentStatusDocumentTransaction({ transaction: transaction, paymentStatusId: paymentStatusId });
      const calledUserInfo: PrivateUserInfo = await getPrivateUserDocument({ transaction: transaction, uid: calledUid });
      const callTransaction: CallTransaction = await getCallTransactionDocument({ transaction: transaction, transactionId: callTransactionId });
      // the final payment indication can come out of order with charge captured, but paid is the final state we care about
      const status = paymentStatus.status == PaymentStatusStates.PAID ? PaymentStatusStates.PAID : PaymentStatusStates.CAPTURABLE_CHANGE_CONFIRMED;

      await updatePaymentStatus({
        transaction: transaction, paymentStatusCancellationReason: paymentStatus.paymentStatusCancellationReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: amountCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: paymentStatus.centsRequestedCapture,
        paymentStatusId: paymentStatusId, chargeId: paymentStatus.chargeId, status: status
      });

      paymentStatus.centsCaptured = amountCaptured;
      paymentStatus.status = status;
      return [paymentStatus, calledUserInfo, callTransaction];
    });
  } catch (error) {
    throw new Error(`Error in PaymentIntentAmountCapturableUpdated: ${error}`);
  }
}
