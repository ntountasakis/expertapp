import 'package:expertapp/src/firebase/firestore/document_models/chat_message.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:expertapp/src/util/time_util.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:flutter/material.dart';

class ChatBubbleWidget extends StatelessWidget {
  final DocumentWrapper<ChatMessage> chatMessage;
  final String currentUserId;

  const ChatBubbleWidget(this.chatMessage, this.currentUserId, {Key? key})
      : super(key: key);

  Widget buildSendChatBubble(DocumentWrapper<ChatMessage> chatMessage) {
    return new ChatBubble(
        clipper: ChatBubbleClipper3(type: BubbleType.sendBubble),
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(top: 20),
        backGroundColor: Colors.blue,
        child: Text(
          chatMessage.documentType.chatText,
          style: TextStyle(color: Colors.white),
        ));
  }

  Widget buildReceiverChatBubble(DocumentWrapper<ChatMessage> chatMessage) {
    return ChatBubble(
      clipper: ChatBubbleClipper3(type: BubbleType.receiverBubble),
      backGroundColor: Color(0xffE7E7ED),
      margin: EdgeInsets.only(top: 20),
      child: Text(
        chatMessage.documentType.chatText,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageTimeStyle = TextStyle(
      fontSize: 12,
    );
    if (chatMessage.documentType.authorUid == currentUserId) {
      return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        buildSendChatBubble(chatMessage),
        SizedBox(
          height: 5,
        ),
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: Text(
            "Sent: " +
                messageTimeAnnotation(
                    chatMessage.documentType.millisecondsSinceEpochUtc),
            style: messageTimeStyle,
          ),
        ),
      ]);
    } else {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        buildReceiverChatBubble(chatMessage),
        SizedBox(
          height: 5,
        ),
        Container(
          margin: const EdgeInsets.only(left: 20),
          child: Text(
            "Received: " +
                messageTimeAnnotation(
                    chatMessage.documentType.millisecondsSinceEpochUtc),
            style: messageTimeStyle,
          ),
        ),
      ]);
    }
  }
}
