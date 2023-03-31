import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/chat_message.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/appbars/user_view/user_preview_appbar.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/util/time_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class CommonViewChatPage extends StatefulWidget {
  final String currentUserUid;
  final String otherUserUid;
  final bool isEditable;

  CommonViewChatPage(
      {required this.currentUserUid,
      required this.otherUserUid,
      required this.isEditable});

  @override
  State<CommonViewChatPage> createState() => _CommonViewChatPageState();
}

class _CommonViewChatPageState extends State<CommonViewChatPage> {
  final chatTextController = TextEditingController();
  String _currentChatMessage = '';

  Future<void> submitChatMessage(String chatroomId) async {
    if (_currentChatMessage.isEmpty) return;
    final msSinceEpochUtc = DateTime.now().millisecondsSinceEpoch;
    final newMessage = ChatMessage(widget.currentUserUid, widget.otherUserUid,
        _currentChatMessage, msSinceEpochUtc);
    await newMessage.put(chatroomId);
    _currentChatMessage = '';
    chatTextController.clear();
  }

  Widget buildChatBar(String chatroomId) => TextField(
      controller: chatTextController,
      minLines: 1,
      maxLines: 5,
      decoration: InputDecoration(
          labelText: "Write Message",
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              await submitChatMessage(chatroomId);
            },
          )),
      onChanged: (String chatMessage) {
        setState(() {
          _currentChatMessage = chatMessage;
        });
      });

  Widget buildSendChatBubble(DocumentWrapper<ChatMessage> chatMessage) {
    return ChatBubble(
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

  Widget buildChatBubble(DocumentWrapper<ChatMessage> chatMessage) {
    final messageTimeStyle = TextStyle(
      fontSize: 12,
    );
    if (chatMessage.documentType.authorUid == widget.currentUserUid) {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: Future.wait([
          PublicUserInfo.get(widget.otherUserUid),
          lookupChatroomId(widget.otherUserUid)
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final otherUserShortName = snapshot.data![0] != null
                ? ((snapshot.data![0] as DocumentWrapper<PublicUserInfo>)
                    .documentType
                    .firstName)
                : "Deleted User";
            final chatroomId = snapshot.data![1] as String;
            return Scaffold(
              appBar: UserPreviewAppbar(otherUserShortName, ""),
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: ChatMessage.getStream(chatroomId),
                      builder: (BuildContext context,
                          AsyncSnapshot<Iterable<DocumentWrapper<ChatMessage>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                DocumentWrapper<ChatMessage> chatMessage =
                                    snapshot.data!.elementAt(index);
                                return buildChatBubble(chatMessage);
                              });
                        } else {
                          return Text("Loading.....");
                        }
                      },
                    ),
                  ),
                  widget.isEditable ? buildChatBar(chatroomId) : SizedBox(),
                  SizedBox(
                    height: 100,
                  )
                ],
              ),
            );
          } else {
            return Scaffold(
              body: CircularProgressIndicator(),
            );
          }
        });
  }
}
