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
  return admin.firestore().collection("chatroom_metadata");
}


export {getUserDocumentRef, getUserMetadataDocumentRef, getReviewsCollectionRef, getChatroomMetadataCollectionRef};
