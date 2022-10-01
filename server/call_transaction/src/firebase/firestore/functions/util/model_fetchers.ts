import * as admin from "firebase-admin";
import {CallTransaction} from "../../models/call_transaction";
import {ExpertRate} from "../../models/expert_rate";
import {PrivateUserInfo} from "../../models/private_user_info";

export async function getExpertRate(expertUid: string, transaction: FirebaseFirestore.Transaction) :
Promise<[errorMessage: string, expertRate: ExpertRate | undefined]> {
  const ratesCollectionRef = admin.firestore().collection("expert_rates");
  const calledRateDoc = await transaction.get(ratesCollectionRef.doc(expertUid));

  if (!calledRateDoc.exists) {
    const errorMessage = `Called User: ${expertUid} does not have a registered rate`;
    return [errorMessage, undefined];
  }
  return ["", calledRateDoc.data() as ExpertRate];
}

export async function getPrivateUserInfo(uid: string, transaction: FirebaseFirestore.Transaction) :
Promise<[errorMessage: string, privateUserInfo: PrivateUserInfo | undefined]> {
  const privateUserInfoRef = admin.firestore().collection("users");
  const privateCallerUserInfoDoc = await transaction.get(privateUserInfoRef.doc(uid));

  if (!privateCallerUserInfoDoc.exists) {
    const errorMessage = `Caller User: ${uid} does not have a private user info`;
    return [errorMessage, undefined];
  }
  return ["", privateCallerUserInfoDoc.data() as PrivateUserInfo];
}

export function getCallTransactionRef(callTransactionId: string) :
  FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  return admin.firestore().collection("call_transactions").doc(callTransactionId);
}

export async function getCallTransaction(callTransactionId: string, transaction: FirebaseFirestore.Transaction) :
Promise<[errorMessage: string, CallTransaction: CallTransaction | undefined]> {
  const callTransactionDoc = await transaction.get(getCallTransactionRef(callTransactionId));
  if (!callTransactionDoc.exists) {
    const errorMessage = `Call Transaction: ${callTransactionId} does not exist`;
    return [errorMessage, undefined];
  }
  return ["", callTransactionDoc.data() as CallTransaction];
}
