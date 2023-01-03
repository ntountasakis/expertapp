import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/util/call_buttons.dart';
import 'package:flutter/material.dart';

class CallWaitingJoin extends StatelessWidget {
  final VoidCallback onCancelCallTap;
  final DocumentWrapper<UserMetadata> calledUserMetadata;

  const CallWaitingJoin(
      {required this.onCancelCallTap, required this.calledUserMetadata});

  Widget buildConnectingDialog() {
    final style = TextStyle(
      fontSize: 20,
    );
    return Text("Connecting...", style: style);
  }

  Widget buildCancelCallButton() {
    return Center(child: endCallButton(onCancelCallTap));
  }

  Widget buildProfilePicture() {
    return SizedBox(
      height: 200,
      width: 200,
      child: ProfilePicture(calledUserMetadata.documentType.profilePicUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        SizedBox(
          height: 15,
        ),
        buildConnectingDialog(),
        SizedBox(
          height: 15,
        ),
        buildProfilePicture(),
        SizedBox(
          height: 15,
        ),
        Center(
          child: buildCancelCallButton(),
        ),
      ],
    ));
  }
}
