import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";

const lookupChatroomId = async (
    // eslint-disable-next-line max-len
    chatroomMetadataCollection: FirebaseFirestore.CollectionReference<FirebaseFirestore.DocumentData>,
    transaction: FirebaseFirestore.Transaction,
    currentUid : string, otherUid : string) : Promise<string> => {
  const existingChatroom = await transaction.get(
      chatroomMetadataCollection
          .where("currentUid", "==", currentUid)
          .where("otherUid", "==", otherUid));

  if (existingChatroom.size > 1) {
    throw new Error(`Chatroom currentUser: ${currentUid} 
            otherUser: ${otherUid} shouldn't have > 1 ChatroomMetadtaa 
            shouldn't have >1 ChatroomMetadata documents.
            Have ${existingChatroom.size}.`);
  }
  if (!existingChatroom.empty) {
    const rawChatroomDoc = existingChatroom.docs.at(0);
    if (rawChatroomDoc == null) {
      throw new Error(`Firestore DB error. 
              Chatroom size 1 yet data is null`);
    }
    return rawChatroomDoc.id;
  }
  return "";
};

export const chatroomLookup = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }

  const currentUid : string = context.auth.uid;
  const otherUid : string = data.otherUid;

  const chatroomId = await admin.firestore()
      .runTransaction(async (transaction) => {
        const chatroomMetadataCollection = admin.firestore()
            .collection("chatroom_metadata");

        {
          const existingRoomId = await lookupChatroomId(
              chatroomMetadataCollection, transaction, currentUid, otherUid);
          if (existingRoomId != "") {
            return existingRoomId;
          }
        }
        {
          const mirroredRoomId = await lookupChatroomId(
              chatroomMetadataCollection, transaction, otherUid, currentUid);
          if (mirroredRoomId != "") {
            return mirroredRoomId;
          }
        }

        const newChatroomId = uuidv4();
        const newChatroomMetadata = {
          "currentUid": currentUid,
          "otherUid": otherUid,
        };

        transaction.set(chatroomMetadataCollection.doc(newChatroomId),
            newChatroomMetadata);

        console.log(`Created new chatroomId: ${newChatroomId} for 
            ${currentUid} and ${otherUid}`);

        return newChatroomId;
      });

  return chatroomId;
});
