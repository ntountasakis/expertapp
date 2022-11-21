import * as functions from "firebase-functions";
import {getUserOwedBalanceDocumentRef} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {UserOwedBalance} from "../../../shared/src/firebase/firestore/models/user_owed_balance";

export const checkOutstandingBalance = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const userUid = context.auth.uid;
  const owedBalanceDoc = await getUserOwedBalanceDocumentRef({uid: userUid}).get();

  if (!owedBalanceDoc.exists) {
    console.log(`User: ${userUid} has no balance doc. Owes 0`);
    return {owedBalanceCents: 0};
  }
  const owedBalance = owedBalanceDoc.data() as UserOwedBalance;
  console.log(`User: ${userUid} owes ${owedBalance.owedBalanceCents}`);
  return {owedBalanceCents: owedBalance.owedBalanceCents};
});
