import * as admin from "firebase-admin";
import { CallTransaction } from "../models/call_transaction";
import { ExpertRate } from "../models/expert_rate";
import { FcmToken } from "../models/fcm_token";
import { PaymentStatus } from "../models/payment_status";
import { PrivateUserInfo } from "../models/private_user_info";
import {CollectionPaths} from "./collection_paths";

function getUserDocumentRef({uid}: {uid: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.USERS).doc(uid);
}

function getUserMetadataDocumentRef({uid}: {uid: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.USER_METADATA).doc(uid);
}

async function getUserMetadataDocument({uid}: {uid: string}): Promise<PrivateUserInfo>
{
  const doc = await getUserMetadataDocumentRef({uid: uid}).get();
  if (!doc.exists)
  {
    throw new Error(`No user metadata with uid: ${uid}`);
  }
  return doc.data() as PrivateUserInfo;
}

function getReviewsCollectionRef():
FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.REVIEWS);
}

function getChatroomMetadataCollectionRef():
FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.CHATROOM_METADATA);
}

function getPaymentStatusDocumentRef({paymentStatusId}: {paymentStatusId: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.PAYMENT_STATUSES).doc(paymentStatusId);
}

async function getPaymentStatusDocument({paymentStatusId}: {paymentStatusId: string}): Promise<PaymentStatus>
{
  const doc = await getPaymentStatusDocumentRef({paymentStatusId: paymentStatusId}).get();
  if (!doc.exists)
  {
    throw new Error(`No payment status with id: ${paymentStatusId}`);
  }
  return doc.data() as PaymentStatus;
}

function getExpertRateDocumentRef({expertUid}: {expertUid: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.EXPERT_RATES).doc(expertUid);
}

async function getExpertRateDocument({expertUid}: {expertUid: string}): Promise<ExpertRate>
{
  const doc = await getExpertRateDocumentRef({expertUid: expertUid}).get();
  if (!doc.exists)
  {
    throw new Error(`No expert rate exists for expert: ${expertUid}`);
  }
  return doc.data() as ExpertRate;
}

function getCallTransactionDocumentRef({transactionId}: {transactionId: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.CALL_TRANSACTIONS).doc(transactionId);
}

async function getCallTransactionDocument({transactionId}: {transactionId: string}): Promise<CallTransaction>
{
  const doc = await getCallTransactionDocumentRef({transactionId: transactionId}).get();
  if (!doc.exists)
  {
    throw new Error(`No CallTransaction with id: ${transactionId}`);
  }
  return doc.data() as CallTransaction;
}

function getFcmTokenDocumentRef({uid}: {uid: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.FCM_TOKENS).doc(uid);
}

async function getFcmTokenDocument({uid}: {uid: string}): Promise<FcmToken> {
  const doc = await getFcmTokenDocumentRef({uid: uid}).get();
  if (!doc.exists)
  {
    throw new Error(`No fcm token for uid: ${uid}`);
  }
  return doc.data() as FcmToken;
}

export {getUserDocumentRef, getUserMetadataDocumentRef, getReviewsCollectionRef,
  getChatroomMetadataCollectionRef, getPaymentStatusDocumentRef, getExpertRateDocumentRef,
  getCallTransactionDocumentRef, getFcmTokenDocumentRef, getCallTransactionDocument,
  getPaymentStatusDocument, getExpertRateDocument, getUserMetadataDocument, getFcmTokenDocument};
