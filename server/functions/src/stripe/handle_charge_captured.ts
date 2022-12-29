import * as admin from "firebase-admin";
import {getPaymentStatusDocumentTransaction, getPrivateUserDocument} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {updatePaymentStatus} from "../../../shared/src/firebase/firestore/functions/update_payment_status";
import {PaymentStatus, PaymentStatusStates} from "../../../shared/src/firebase/firestore/models/payment_status";
import {PrivateUserInfo} from "../../../shared/src/firebase/firestore/models/private_user_info";
import createStripePaymentTransfer from "../../../shared/src/stripe/payment_transfer_creator";

export async function handleChargeCaptured(payload: any): Promise<void> {
  //   const livemode: boolean = payload.livemode;
  const amountCaptured: number = payload.amount_captured;
  const paymentStatusId: string = payload.metadata.payment_status_id;
  const callerUid: string = payload.metadata.caller_uid;
  const calledUid: string = payload.metadata.called_uid;

  if (paymentStatusId == undefined) {
    console.error("Cannot handle PaymentIntentAmountCapturableUpdated. PaymentId undefined");
    return;
  }
  if (callerUid == undefined) {
    console.error("Cannot handle PaymentIntentAmountCapturableUpdated. Uid undefined");
    return;
  }

  const [paymentStatus, calledUserInfo] =
    await updatePaymentStateChargeCaptured({paymentStatusId: paymentStatusId, amountCaptured: amountCaptured, calledUid: calledUid});

  const transferId: string = await createStripePaymentTransfer({connectedAccountId: calledUserInfo.stripeConnectedId,
    amountToTransferInCents: amountCaptured, transferGroup: paymentStatus.transferGroup,
    sourceChargeId: paymentStatus.chargeId});

  console.log(`Transferred ${amountCaptured} cents with tranfser id: ${transferId} to calledUid: ${calledUid} 
    connectedAccountId: ${calledUserInfo.stripeConnectedId}`);
}

async function updatePaymentStateChargeCaptured({paymentStatusId, amountCaptured, calledUid}:
  {paymentStatusId: string, amountCaptured: number, calledUid: string}): Promise<[PaymentStatus, PrivateUserInfo]> {
  try {
    return await admin.firestore().runTransaction(async (transaction) => {
      const paymentStatus = await getPaymentStatusDocumentTransaction({transaction: transaction, paymentStatusId: paymentStatusId});
      const calledUserInfo = await getPrivateUserDocument({transaction: transaction, uid: calledUid});
      // the final payment indication can come out of order with charge captured, but paid is the final state we care about
      const status = paymentStatus.status == PaymentStatusStates.PAID ? PaymentStatusStates.PAID : PaymentStatusStates.CAPTURABLE_CHANGE_CONFIRMED;

      await updatePaymentStatus({transaction: transaction, paymentStatusCancellationReason: paymentStatus.paymentStatusCancellationReason,
        centsAuthorized: paymentStatus.centsAuthorized, centsCaptured: amountCaptured, centsPaid: paymentStatus.centsPaid,
        centsRequestedAuthorized: paymentStatus.centsRequestedAuthorized, centsRequestedCapture: paymentStatus.centsRequestedCapture,
        paymentStatusId: paymentStatusId, chargeId: paymentStatus.chargeId, status: status});

      paymentStatus.centsCaptured = amountCaptured;
      paymentStatus.status = status;
      return [paymentStatus, calledUserInfo];
    });
  } catch (error) {
    throw new Error(`Error in PaymentIntentAmountCapturableUpdated: ${error}`);
  }
}
