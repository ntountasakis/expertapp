import {getChatroomMetadataCollectionRef} from "../document_fetchers/fetchers";

async function getChatroomIdOneSided({transaction, lhsUserUid, rhsUserUid}:
    {transaction: FirebaseFirestore.Transaction, lhsUserUid: string, rhsUserUid: string}):
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
    {transaction: FirebaseFirestore.Transaction, lhsUserUid: string, rhsUserUid: string}):
    Promise<string> {
  const existingRoomId = await getChatroomIdOneSided(
      {transaction: transaction, lhsUserUid: lhsUserUid, rhsUserUid: rhsUserUid});
  if (existingRoomId != "") {
    return existingRoomId;
  }
  return await getChatroomIdOneSided({transaction: transaction, lhsUserUid: rhsUserUid, rhsUserUid: lhsUserUid});
}
