import * as admin from "firebase-admin";
import { PublicExpertInfo } from "../models/public_expert_info";
import { CallTransaction } from "../models/call_transaction";
import { ExpertRate } from "../models/expert_rate";
import { FcmToken } from "../models/fcm_token";
import { PaymentStatus } from "../models/payment_status";
import { PrivateUserInfo } from "../models/private_user_info";
import { CollectionPaths } from "./collection_paths";
import { PublicUserInfo } from "../models/public_user_info";

function getExpertCategoryRef({ majorCategory }: { majorCategory: string }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.EXPERT_CATEGORIES).doc(majorCategory);
}

function getPublicUserDocumentRef({ uid }: { uid: string }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.PUBLIC_USER_INFO).doc(uid);
}

async function getPublicUserDocument({ transaction, uid }: { transaction: FirebaseFirestore.Transaction, uid: string }): Promise<PublicUserInfo> {
  const doc = await transaction.get(getPublicUserDocumentRef({ uid: uid }));
  if (!doc.exists) {
    throw new Error(`No public user info with uid: ${uid}`);
  }
  return doc.data() as PublicUserInfo;
}

async function getPublicUserDocumentNoTransact({ uid }: { uid: string }): Promise<PublicUserInfo> {
  const doc = await getPublicUserDocumentRef({ uid: uid }).get();
  if (!doc.exists) {
    throw new Error(`No public user info with uid: ${uid}`);
  }
  return doc.data() as PublicUserInfo;
}


function getPrivateUserDocumentRef({ uid }: { uid: string }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.PRIVATE_USER_INFO).doc(uid);
}

async function getPrivateUserDocument({ transaction, uid }: { transaction: FirebaseFirestore.Transaction, uid: string }): Promise<PrivateUserInfo> {
  const doc = await transaction.get(getPrivateUserDocumentRef({ uid: uid }));
  if (!doc.exists) {
    throw new Error(`No private user info with uid: ${uid}`);
  }
  return doc.data() as PrivateUserInfo;
}

async function getPrivateUserDocumentNoTransact({ uid }: { uid: string }): Promise<PrivateUserInfo> {
  const doc = await getPrivateUserDocumentRef({ uid: uid }).get();
  if (!doc.exists) {
    throw new Error(`No private user info with uid: ${uid}`);
  }
  return doc.data() as PrivateUserInfo;
}

function getPublicExpertInfoDocumentRef({ uid, fromSignUpFlow }: { uid: string, fromSignUpFlow: boolean }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(fromSignUpFlow ? CollectionPaths.PUBLIC_EXPERT_INFO_STAGING : CollectionPaths.PUBLIC_EXPERT_INFO).doc(uid);
}

function getExpertSignUpProgressDocumentRef({ uid }: { uid: string }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.EXPERT_SIGNUP_PROGRESS).doc(uid);
}

async function getPublicExpertInfo({ transaction, uid }: { transaction: FirebaseFirestore.Transaction, uid: string }): Promise<PublicExpertInfo> {
  const doc = await transaction.get(getPublicExpertInfoDocumentRef({ uid: uid, fromSignUpFlow: false }));
  if (!doc.exists) {
    throw new Error(`No public expert info with uid: ${uid}`);
  }
  return doc.data() as PublicExpertInfo;
}

function getReviewsCollectionRef():
  FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.REVIEWS);
}

function getChatroomMetadataCollectionRef():
  FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.CHATROOM_METADATA);
}

function getChatroomCollectionRef():
  FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.CHATROOMS);
}

function getPaymentStatusDocumentRef({ paymentStatusId }: { paymentStatusId: string }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.PAYMENT_STATUSES).doc(paymentStatusId);
}

async function getPaymentStatusDocument({ paymentStatusId }: { paymentStatusId: string }): Promise<PaymentStatus> {
  const doc = await getPaymentStatusDocumentRef({ paymentStatusId: paymentStatusId }).get();
  if (!doc.exists) {
    throw new Error(`No payment status with id: ${paymentStatusId}`);
  }
  return doc.data() as PaymentStatus;
}

async function getPaymentStatusDocumentTransaction({ paymentStatusId, transaction }: { paymentStatusId: string, transaction: FirebaseFirestore.Transaction }): Promise<PaymentStatus> {
  const doc = await transaction.get(getPaymentStatusDocumentRef({ paymentStatusId: paymentStatusId }));
  if (!doc.exists) {
    throw new Error(`No payment status with id: ${paymentStatusId}`);
  }
  return doc.data() as PaymentStatus;
}

function getExpertRateDocumentRef({ expertUid }: { expertUid: string }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.EXPERT_RATES).doc(expertUid);
}

async function getExpertRateDocument({ transaction, expertUid }: { transaction: FirebaseFirestore.Transaction, expertUid: string }): Promise<ExpertRate> {
  const doc = await transaction.get(getExpertRateDocumentRef({ expertUid: expertUid }));
  if (!doc.exists) {
    throw new Error(`No expert rate exists for expert: ${expertUid}`);
  }
  return doc.data() as ExpertRate;
}

function getCallTransactionCollectionRef():
  FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.CALL_TRANSACTIONS);
}

function getCallTransactionDocumentRef({ transactionId }: { transactionId: string }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return getCallTransactionCollectionRef().doc(transactionId);
}

async function getCallTransactionDocument({ transaction, transactionId }:
  { transaction: FirebaseFirestore.Transaction, transactionId: string }): Promise<CallTransaction> {
  const doc = await transaction.get(getCallTransactionDocumentRef({ transactionId: transactionId }));
  if (!doc.exists) {
    throw new Error(`No CallTransaction with id: ${transactionId}`);
  }
  return doc.data() as CallTransaction;
}

function getFcmTokenDocumentRef({ uid }: { uid: string }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.FCM_TOKENS).doc(uid);
}

function getStatusDocumentRef({ uid }: { uid: string }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.STATUS).doc(uid);
}

function getSignUpTokenDocumentRef({ token }: { token: string }):
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.SIGN_UP_TOKENS).doc(token);
}

async function getFcmTokenDocument({ transaction, uid }: { transaction: FirebaseFirestore.Transaction, uid: string }): Promise<FcmToken> {
  const doc = await transaction.get(getFcmTokenDocumentRef({ uid: uid }));
  if (!doc.exists) {
    throw new Error(`No fcm token for uid: ${uid}`);
  }
  return doc.data() as FcmToken;
}

export {
  getPrivateUserDocumentRef, getPublicExpertInfoDocumentRef, getReviewsCollectionRef,
  getChatroomMetadataCollectionRef, getChatroomCollectionRef, getPaymentStatusDocumentRef, getExpertRateDocumentRef,
  getCallTransactionDocumentRef, getCallTransactionCollectionRef, getFcmTokenDocumentRef, getCallTransactionDocument,
  getPaymentStatusDocument, getPaymentStatusDocumentTransaction, getExpertRateDocument, getPublicExpertInfo,
  getFcmTokenDocument, getPrivateUserDocument, getPrivateUserDocumentNoTransact, getSignUpTokenDocumentRef,
  getPublicUserDocumentRef, getPublicUserDocument, getPublicUserDocumentNoTransact, getExpertCategoryRef,
  getExpertSignUpProgressDocumentRef, getStatusDocumentRef
};
