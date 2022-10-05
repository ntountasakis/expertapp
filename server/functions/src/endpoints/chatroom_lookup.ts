import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getChatroomId} from "../../../shared/firebase/firestore/functions/get_chatroom_id";
import {createChatroom} from "../../../shared/firebase/firestore/functions/create_chatroom";

export const chatroomLookup = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const currentUid : string = context.auth.uid;
  const otherUid : string = data.otherUid;

  return await admin.firestore().runTransaction(async (transaction) => {
    const existingChatroomId = await getChatroomId({
      transaction: transaction, lhsUserUid: currentUid, rhsUserUid: otherUid,
    });
    if (existingChatroomId != "") return existingChatroomId;

    const newChatroomId = await createChatroom({transaction: transaction, currentUid: currentUid, otherUid: otherUid});
    console.log(`Created new chatroomId: ${newChatroomId} for ${currentUid} and ${otherUid}`);
    return newChatroomId;
  });
});
