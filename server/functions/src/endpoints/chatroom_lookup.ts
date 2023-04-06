import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { getChatroomId } from "../../../shared/src/firebase/firestore/functions/chatroom_util";
import { createChatroom } from "../../../shared/src/firebase/firestore/functions/create_chatroom";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";

export const chatroomLookup = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const currentUid: string = context.auth.uid;
  const otherUid: string = data.otherUid;

  return await admin.firestore().runTransaction(async (transaction) => {
    const existingChatroomId = await getChatroomId({
      transaction: transaction, lhsUserUid: currentUid, rhsUserUid: otherUid,
    });
    if (existingChatroomId != "") return existingChatroomId;

    const newChatroomId = await createChatroom({ transaction: transaction, currentUid: currentUid, otherUid: otherUid });
    Logger.log({
      logName: "chatroomLookup", message: `Created new chatroomId: ${newChatroomId} for ${currentUid} and ${otherUid}`,
      labels: new Map([["chatroomId", newChatroomId], ["currentUid", currentUid], ["otherUid", otherUid]]),
    });
    return newChatroomId;
  });
});
