import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/chat_page.dart';
import 'package:flutter/material.dart';

// todo: pass flag to make chat page editable, and view-only otherwise
Widget buildEditableChatButton({required BuildContext context, required String currentUserId, 
required DocumentWrapper<UserMetadata> calledUserMetadata}) {
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  return ElevatedButton(
      style: style,
      onPressed: () async {
        final chatroomId =
            await lookupChatroomId(calledUserMetadata.documentId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
                currentUserId, calledUserMetadata, chatroomId),
          ),
        );
      },
      child: const Text('Chat Expert'));
}
