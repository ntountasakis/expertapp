import { getCallTransactionDocumentRef, getExpertRateDocumentRef, getUserDocumentRef } from "../../../../../../shared/firebase/firestore/document_fetchers/fetchers";
import { CallTransaction } from "../../../../../../shared/firebase/firestore/models/call_transaction";
import { ExpertRate } from "../../../../../../shared/firebase/firestore/models/expert_rate";
import { PrivateUserInfo } from "../../../../../../shared/firebase/firestore/models/private_user_info";

export async function getExpertRate(expertUid: string, transaction: FirebaseFirestore.Transaction) :
Promise<[errorMessage: string, expertRate: ExpertRate | undefined]> {
  const calledRateDoc = await transaction.get(getExpertRateDocumentRef({expertUid: expertUid}));

  if (!calledRateDoc.exists) {
    const errorMessage = `Called User: ${expertUid} does not have a registered rate`;
    return [errorMessage, undefined];
  }
  return ["", calledRateDoc.data() as ExpertRate];
}

export async function getPrivateUserInfo(uid: string, transaction: FirebaseFirestore.Transaction) :
Promise<[errorMessage: string, privateUserInfo: PrivateUserInfo | undefined]> {
  const privateCallerUserInfoDoc = await transaction.get(getUserDocumentRef({uid: uid}));

  if (!privateCallerUserInfoDoc.exists) {
    const errorMessage = `Caller User: ${uid} does not have a private user info`;
    return [errorMessage, undefined];
  }
  return ["", privateCallerUserInfoDoc.data() as PrivateUserInfo];
}

export async function getCallTransaction(callTransactionId: string, transaction: FirebaseFirestore.Transaction) :
Promise<[errorMessage: string, CallTransaction: CallTransaction | undefined]> {
  const callTransactionDoc = await transaction.get(getCallTransactionDocumentRef({transactionId: callTransactionId}));
  if (!callTransactionDoc.exists) {
    const errorMessage = `Call Transaction: ${callTransactionId} does not exist`;
    return [errorMessage, undefined];
  }
  return ["", callTransactionDoc.data() as CallTransaction];
}
