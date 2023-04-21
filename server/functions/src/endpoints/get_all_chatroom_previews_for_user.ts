import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {getChatroomPreviews} from "../../../shared/src/firebase/firestore/functions/chatroom_util";
import {ChatroomPreview} from "../../../shared/src/firebase/firestore/models/chatroom_preview";

export const getAllChatroomPreviewsForUser = functions.https.onCall(async (_data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const uid: string = context.auth.uid;
  const previews: ChatroomPreview[] = await admin.firestore().runTransaction(async (transaction) => {
    return await getChatroomPreviews({transaction: transaction, uid: uid});
  });
  return previews;
});
