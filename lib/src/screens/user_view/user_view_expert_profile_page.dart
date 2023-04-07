import 'package:expertapp/src/appbars/user_view/expert_profile_appbar.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_call_action_buttons.dart';
import 'package:expertapp/src/profile/expert/expert_profile_about_me.dart';
import 'package:expertapp/src/profile/expert/expert_profile_header.dart';
import 'package:expertapp/src/profile/expert/expert_profile_reviews.dart';
import 'package:flutter/material.dart';

class UserViewExpertProfilePage extends StatefulWidget {
  final String? _currentUid;
  final String _expertUid;

  UserViewExpertProfilePage(this._currentUid, this._expertUid);

  @override
  State<UserViewExpertProfilePage> createState() =>
      _UserViewExpertProfilePageState();
}

class _UserViewExpertProfilePageState extends State<UserViewExpertProfilePage> {
  final _descriptionScrollController = ScrollController();

  Widget buildBody(BuildContext context,
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      final publicExpertInfo = snapshot.data!;
      return Column(
        children: [
          SizedBox(height: 10),
          buildExpertProfileHeaderUserView(context, publicExpertInfo),
          SizedBox(height: 10),
          buildExpertProfileAboutMeUserView(
              context, publicExpertInfo, _descriptionScrollController),
          buildExpertProfileReviewHeading(),
          buildExpertProfileReviewList(publicExpertInfo),
          buildExpertProfileCallActionButton(
              context, publicExpertInfo, widget._currentUid),
          SizedBox(height: 30),
        ],
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  PreferredSizeWidget buildAppbar(
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      return ExpertProfileAppbar(expertUid: snapshot.data!.documentId);
    }
    return AppBar(
      title: Text("Loading..."),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentWrapper<PublicExpertInfo>?>(
        stream: PublicExpertInfo.getStreamForUser(widget._expertUid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
          return Scaffold(
            appBar: buildAppbar(snapshot),
            body: buildBody(context, snapshot),
          );
        });
  }
}
