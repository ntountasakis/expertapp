import 'package:expertapp/src/util/chat_bubble_widget.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/chat_message.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/appbars/user_view/user_preview_appbar.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:flutter/material.dart';

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
                                return new ChatBubbleWidget(
                                  chatMessage,
                                  widget.currentUserUid,
                                  key: Key(chatMessage.documentId),
                                );
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
