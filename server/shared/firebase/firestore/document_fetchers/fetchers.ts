import * as admin from "firebase-admin";
import {CollectionPaths} from "./collection_paths";

function getUserDocumentRef({uid}: {uid: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.USERS).doc(uid);
}

function getUserMetadataDocumentRef({uid}: {uid: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.USER_METADATA).doc(uid);
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

function getExpertRateDocumentRef({expertUid}: {expertUid: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.EXPERT_RATES).doc(expertUid);
}

function getCallTransactionDocumentRef({transactionId}: {transactionId: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.CALL_TRANSACTIONS).doc(transactionId);
}

function getFcmTokenDocumentRef({uid}: {uid: string}):
FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection(CollectionPaths.FCM_TOKENS).doc(uid);
}


export {getUserDocumentRef, getUserMetadataDocumentRef, getReviewsCollectionRef,
  getChatroomMetadataCollectionRef, getPaymentStatusDocumentRef, getExpertRateDocumentRef,
  getCallTransactionDocumentRef, getFcmTokenDocumentRef};
