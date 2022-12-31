import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/widgets/call_time_remaining.dart';
import 'package:expertapp/src/screens/appbars/widgets/cost_button.dart';
import 'package:flutter/material.dart';

class ClientInCallAppbar extends StatelessWidget with PreferredSizeWidget {
  final DocumentWrapper<UserMetadata> userMetadata;
  final String namePrefix;
  final CallServerModel model;
  final timeRemainingWidget = new CallTimeRemaining();

  ClientInCallAppbar(this.userMetadata, this.namePrefix, this.model);

  String buildTitle() {
    return namePrefix + " " + userMetadata.documentType.firstName;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(buildTitle()),
          ),
          SizedBox(
            width: 15,
          ),
          timeRemainingWidget,
          SizedBox(
            width: 15,
          ),
          costButton(context, model),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
