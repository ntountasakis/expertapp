import 'package:expertapp/src/firebase/firestore/document_models/chat_message.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:expertapp/src/util/time_util.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatBubbleWidget extends StatelessWidget {
  final DocumentWrapper<ChatMessage> chatMessage;
  final String currentUserId;

  const ChatBubbleWidget(this.chatMessage, this.currentUserId, {Key? key})
      : super(key: key);

  Widget chatBubbleBuilderHelper(
      DocumentWrapper<ChatMessage> chatMessage,
      BubbleType bubbleType,
      Color backgroundColor,
      Color textColor,
      Color linkColor) {
    return ChatBubble(
        clipper: ChatBubbleClipper3(type: bubbleType),
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(top: 20),
        backGroundColor: backgroundColor,
        child: SelectableLinkify(
          key: ValueKey(chatMessage.documentId),
          enableInteractiveSelection: true,
          text: chatMessage.documentType.chatText,
          style: TextStyle(color: textColor),
          linkStyle: TextStyle(color: linkColor),
          contextMenuBuilder: (context, editableTextState) {
            return AdaptiveTextSelectionToolbar.buttonItems(
              anchors: editableTextState.contextMenuAnchors,
              buttonItems: <ContextMenuButtonItem>[
                ContextMenuButtonItem(
                  onPressed: () {
                    editableTextState
                        .copySelection(SelectionChangedCause.toolbar);
                  },
                  type: ContextMenuButtonType.copy,
                ),
                ContextMenuButtonItem(
                  onPressed: () {
                    editableTextState.selectAll(SelectionChangedCause.toolbar);
                  },
                  type: ContextMenuButtonType.selectAll,
                ),
              ],
            );
          },
          onOpen: (link) async {
            await launchUrl(Uri.parse(link.url));
          },
        ));
  }

  Widget buildSendChatBubble(DocumentWrapper<ChatMessage> chatMessage) {
    return chatBubbleBuilderHelper(chatMessage, BubbleType.sendBubble,
        Colors.blue, Colors.white, Colors.blue[900]!);
  }

  Widget buildReceiverChatBubble(DocumentWrapper<ChatMessage> chatMessage) {
    return chatBubbleBuilderHelper(chatMessage, BubbleType.receiverBubble,
        Color(0xffE7E7ED), Colors.black, Colors.blue);
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
