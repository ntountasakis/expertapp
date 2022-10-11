import * as admin from "firebase-admin";
import { UserMetadata } from "../models/user_metadata";
import { CallTransaction } from "../models/call_transaction";
import { ExpertRate } from "../models/expert_rate";
import { FcmToken } from "../models/fcm_token";
import { PaymentStatus } from "../models/payment_status";
import { PrivateUserInfo } from "../models/private_user_info";
import {CollectionPaths} from "./collection_paths";

function getPrivateUserDocumentRef({uid}: {uid: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.USERS).doc(uid);
}

async function getPrivateUserDocument({transaction, uid}: {transaction: FirebaseFirestore.Transaction, uid: string}): Promise<PrivateUserInfo>
{
  const doc = await transaction.get(getPrivateUserDocumentRef({uid: uid}));
  if (!doc.exists)
  {
    throw new Error(`No user with uid: ${uid}`);
  }
  return doc.data() as PrivateUserInfo;
}

async function getPrivateUserDocumentNoTransact({uid}: {uid: string}): Promise<PrivateUserInfo>
{
  const doc = await getPrivateUserDocumentRef({uid: uid}).get();
  if (!doc.exists)
  {
    throw new Error(`No user with uid: ${uid}`);
  }
  return doc.data() as PrivateUserInfo;
}

function getUserMetadataDocumentRef({uid}: {uid: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.USER_METADATA).doc(uid);
}

async function getUserMetadataDocument({transaction, uid}: {transaction: FirebaseFirestore.Transaction, uid: string}): Promise<UserMetadata>
{
  const doc = await transaction.get(getUserMetadataDocumentRef({uid: uid}));
  if (!doc.exists)
  {
    throw new Error(`No user metadata with uid: ${uid}`);
  }
  return doc.data() as UserMetadata;
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
 
async function getExpertRateDocument({transaction, expertUid}: {transaction: FirebaseFirestore.Transaction, expertUid: string}): Promise<ExpertRate>
{
  const doc = await transaction.get(getExpertRateDocumentRef({expertUid: expertUid}));
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

async function getCallTransactionDocument({transaction, transactionId}: 
  {transaction: FirebaseFirestore.Transaction, transactionId: string}): Promise<CallTransaction>
{
  const doc = await transaction.get(getCallTransactionDocumentRef({transactionId: transactionId}));
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

async function getFcmTokenDocument({transaction, uid}: {transaction: FirebaseFirestore.Transaction, uid: string}): Promise<FcmToken> {
  const doc = await transaction.get(getFcmTokenDocumentRef({uid: uid}));
  if (!doc.exists)
  {
    throw new Error(`No fcm token for uid: ${uid}`);
  }
  return doc.data() as FcmToken;
}

export {getPrivateUserDocumentRef as getUserDocumentRef, getUserMetadataDocumentRef, getReviewsCollectionRef,
  getChatroomMetadataCollectionRef, getPaymentStatusDocumentRef, getExpertRateDocumentRef,
  getCallTransactionDocumentRef, getFcmTokenDocumentRef, getCallTransactionDocument,
  getPaymentStatusDocument, getExpertRateDocument, getUserMetadataDocument, getFcmTokenDocument,
  getPrivateUserDocument, getPrivateUserDocumentNoTransact};