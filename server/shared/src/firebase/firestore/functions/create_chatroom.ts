import {v4 as uuidv4} from "uuid";
import { getChatroomMetadataCollectionRef } from "../document_fetchers/fetchers";
import { ChatroomMetadata } from "../models/chatroom_metadata";

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
