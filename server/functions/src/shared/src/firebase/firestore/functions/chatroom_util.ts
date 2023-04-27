import {getChatroomCollectionRef, getChatroomMetadataCollectionRef} from "../document_fetchers/fetchers";
import {ChatroomPreview} from "../models/chatroom_preview";
import {ChatMessage} from "../models/chat_message";

async function getChatroomIdOneSided({transaction, lhsUserUid, rhsUserUid}:
  { transaction: FirebaseFirestore.Transaction, lhsUserUid: string, rhsUserUid: string }):
  Promise<string> {
  const existingChatroom = await transaction.get(getChatroomMetadataCollectionRef()
      .where("currentUid", "==", lhsUserUid)
      .where("otherUid", "==", rhsUserUid));

  if (existingChatroom.size > 1) {
    throw new Error(`Chatroom currentUser: ${lhsUserUid} 
            otherUser: ${rhsUserUid} shouldn't have > 1 ChatroomMetadtaa 
            shouldn't have >1 ChatroomMetadata documents.
            Have ${existingChatroom.size}.`);
  }
  if (!existingChatroom.empty) {
    const rawChatroomDoc = existingChatroom.docs.at(0);
    if (rawChatroomDoc == null) {
      throw new Error("Firestore DB error. Chatroom size 1 yet data is null");
    }
    return rawChatroomDoc.id;
  }
  return "";
}

export async function getChatroomId({transaction, lhsUserUid, rhsUserUid}:
  { transaction: FirebaseFirestore.Transaction, lhsUserUid: string, rhsUserUid: string }):
  Promise<string> {
  const existingRoomId = await getChatroomIdOneSided(
      {transaction: transaction, lhsUserUid: lhsUserUid, rhsUserUid: rhsUserUid});
  if (existingRoomId != "") {
    return existingRoomId;
  }
  return await getChatroomIdOneSided({transaction: transaction, lhsUserUid: rhsUserUid, rhsUserUid: lhsUserUid});
}


async function getChatroomPreviewsOneSided({transaction, uidKey, uid}:
  { transaction: FirebaseFirestore.Transaction, uidKey: string, uid: string }):
  Promise<ChatroomPreview[]> {
  const metadata = await transaction.get(getChatroomMetadataCollectionRef().where(uidKey, "==", uid));
  const chatroomPreviews: ChatroomPreview[] = [];

  // eslint-disable-next-line guard-for-in
  for (const docIdx in metadata.docs) {
    const chatroomId = metadata.docs[docIdx].id;
    const lastMessage = await transaction.get(getChatroomCollectionRef()
        .doc(chatroomId)
        .collection("chat_messages")
        .orderBy("millisecondsSinceEpochUtc", "desc")
        .limit(1));
    if (!lastMessage.empty) {
      const chatMessageDoc = lastMessage.docs[0].data() as ChatMessage;
      chatroomPreviews.push({
        "otherUid": chatMessageDoc.authorUid == uid ? chatMessageDoc.recipientUid : chatMessageDoc.authorUid,
        "lastMessage": chatMessageDoc.chatText,
        "lastMessageSenderUid": chatMessageDoc.authorUid,
        "lastMessageMillisecondsSinceEpochUtc": chatMessageDoc.millisecondsSinceEpochUtc,
      });
    }
  }
  return chatroomPreviews;
}

function sortChatroomPreviewsByNewest(chatroomPreviews: ChatroomPreview[]): ChatroomPreview[] {
  return chatroomPreviews.sort((a, b) => {
    if (a.lastMessageMillisecondsSinceEpochUtc > b.lastMessageMillisecondsSinceEpochUtc) {
      return -1;
    }
    if (a.lastMessageMillisecondsSinceEpochUtc < b.lastMessageMillisecondsSinceEpochUtc) {
      return 1;
    }
    return 0;
  });
}

export async function getChatroomPreviews({transaction, uid}: { transaction: FirebaseFirestore.Transaction, uid: string }): Promise<ChatroomPreview[]> {
  const chatroomPreviews = await getChatroomPreviewsOneSided({transaction: transaction, uidKey: "currentUid", uid: uid});
  chatroomPreviews.push(...await getChatroomPreviewsOneSided({transaction: transaction, uidKey: "otherUid", uid: uid}));
  const sortedPreview = sortChatroomPreviewsByNewest(chatroomPreviews);
  return sortedPreview;
}
