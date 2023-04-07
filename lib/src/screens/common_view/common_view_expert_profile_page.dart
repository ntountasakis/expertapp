import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/appbars/user_view/expert_profile_appbar.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/expert/expert_call_action_buttons.dart';
import 'package:expertapp/src/profile/expert/expert_profile_about_me.dart';
import 'package:expertapp/src/profile/expert/expert_profile_header.dart';
import 'package:expertapp/src/profile/expert/expert_profile_reviews.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CommonViewExpertProfilePage extends StatefulWidget {
  final String? _currentUid;
  final String _expertUid;
  final bool _isEditable;
  final bool _fromExpertSignupflow;

  CommonViewExpertProfilePage(this._currentUid, this._expertUid,
      this._isEditable, this._fromExpertSignupflow);

  @override
  State<CommonViewExpertProfilePage> createState() =>
      _CommonViewExpertProfilePageState(new ExpertCategorySelector(_expertUid));
}

class _CommonViewExpertProfilePageState
    extends State<CommonViewExpertProfilePage> {
  final _descriptionScrollController = ScrollController();
  final ExpertCategorySelector _categorySelector;
  late TextEditingController _textController;
  String _textControllerText = "Loading...";

  _CommonViewExpertProfilePageState(this._categorySelector);

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.text = _textControllerText;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void updateProfileDescriptionIfChanged(
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) async {
    if (publicExpertInfo.documentType.description != _textControllerText) {
      _textControllerText = publicExpertInfo.documentType.description;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _textController.text = _textControllerText;
      });
    }
  }

  Widget buildBody(BuildContext context,
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      final publicExpertInfo = snapshot.data;
      updateProfileDescriptionIfChanged(publicExpertInfo!);
      return Column(
        children: [
          SizedBox(height: 10),
          widget._isEditable
              ? buildExpertProfileHeaderExpertView(
                  context, publicExpertInfo, _textController, _categorySelector)
              : SizedBox(height: 10),
          widget._isEditable
              ? buildExpertProfileAboutMeExpertView(context, publicExpertInfo,
                  _descriptionScrollController, _textController)
              : buildExpertProfileAboutMeUserView(
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
      if (widget._fromExpertSignupflow) {
        return ExpertPostSignupAppbar(
          uid: widget._expertUid,
          titleText: "Click arrow to finish",
          nextRoute: Routes.HOME_PAGE,
          addAdditionalParams: false,
          allowBackButton: true,
        );
      } else {
        return ExpertProfileAppbar(expertUid: snapshot.data!.documentId);
      }
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
