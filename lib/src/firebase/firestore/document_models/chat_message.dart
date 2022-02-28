import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class ChatMessage {
  final String authorUid;
  final String recipientUid;
  final String chatText;
  final int millisecondsSinceEpochUtc;

  ChatMessage(this.authorUid, this.recipientUid, this.chatText,
      this.millisecondsSinceEpochUtc);

  ChatMessage.fromJson(Map<String, dynamic> json)
      : this(
            json['authorUid'] as String,
            json['recipientUid'] as String,
            json['chatText'] as String,
            json['millisecondsSinceEpochUtc'] as int);

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'authorUid': authorUid,
      'recipientUid': recipientUid,
      'chatText': chatText,
      'millisecondsSinceEpochUtc': millisecondsSinceEpochUtc,
    };
    return fieldsMap;
  }

  static Stream<Iterable<DocumentWrapper<ChatMessage>>> getStream(
      String chatroomId) {
    return _chatMessageRef(chatroomId)
        .orderBy('millisecondsSinceEpochUtc', descending: false)
        .snapshots()
        .map((QuerySnapshot<ChatMessage> collectionSnapshot) {
      return collectionSnapshot.docs
          .map((QueryDocumentSnapshot<ChatMessage> documentSnapshot) {
        return DocumentWrapper(documentSnapshot.id, documentSnapshot.data());
      });
    });
  }

  Future<DocumentWrapper<ChatMessage>> put(String chatRoomId) async {
    DocumentReference<ChatMessage> reviewRef =
        await _chatMessageRef(chatRoomId).add(this);
    return DocumentWrapper(reviewRef.id, this);
  }

  static CollectionReference<ChatMessage> _chatMessageRef(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.CHAT_ROOMS)
        .doc(chatRoomId)
        .collection(CollectionPaths.CHAT_MESSAGES)
        .withConverter<ChatMessage>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              ChatMessage.fromJson(snapshot.data()!),
          toFirestore: (ChatMessage chatMessage, _) => chatMessage._toJson(),
        );
  }
}
