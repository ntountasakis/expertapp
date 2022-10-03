import {ChatroomMetadata} from "../../../../../shared/firebase/firestore/models/chatroom_metadata";
import {v4 as uuidv4} from "uuid";
import { getChatroomMetadataCollectionRef } from "../../../../../shared/firebase/firestore/document_fetchers/fetchers";

export async function createChatroom({transaction, currentUid, otherUid} :
    { transaction: FirebaseFirestore.Transaction, currentUid: string, otherUid: string}): Promise<string> {
  const newChatroomMetadata: ChatroomMetadata = {
    "currentUid": currentUid,
    "otherUid": otherUid,
  };

  const newChatroomId = uuidv4();
  transaction.set(getChatroomMetadataCollectionRef().doc(newChatroomId), newChatroomMetadata);

  return newChatroomId;
}
