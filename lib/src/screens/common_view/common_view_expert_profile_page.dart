import 'dart:developer';
import 'dart:typed_data';

import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/expert/expert_rating.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/profile/expert/expert_reviews.dart';
import 'package:expertapp/src/timezone/timezone_util.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

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

  Widget buildCallButtonHelper(
      Color backgroundColor,
      Color shadowColor,
      String buttonText,
      String routeName,
      Map<String, String> params,
      bool shouldPush) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      backgroundColor: backgroundColor,
      elevation: 4.0,
      shadowColor: shadowColor,
    );
    return Row(
      children: [
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
              style: style,
              onPressed: () async {
                if (shouldPush) {
                  context.pushNamed(routeName, params: params);
                } else {
                  context.pushReplacementNamed(routeName, params: params);
                }
              },
              child: Text(buttonText)),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget buildMakeAccountButton(BuildContext context) {
    return buildCallButtonHelper(
        Colors.blue[500]!,
        Colors.blue[900]!,
        'Make an account / sign in to call this expert',
        Routes.SIGN_IN_PAGE,
        {},
        false);
  }

  Widget buildCallPreviewButton(BuildContext context,
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return buildCallButtonHelper(
        Colors.green[500]!,
        Colors.green[900]!,
        'Call ${publicExpertInfo.documentType.firstName}',
        Routes.UV_EXPERT_CALL_PREVIEW_PAGE,
        {Routes.EXPERT_ID_PARAM: publicExpertInfo.documentId},
        true);
  }

  Widget buildCallUnableShowInCallStatus(BuildContext context,
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return buildCallButtonHelper(
        Colors.red[500]!,
        Colors.red[900]!,
        'They are currently in another call. Please come back later.',
        Routes.UV_VIEW_EXPERT_AVAILABILITY_PAGE,
        {Routes.EXPERT_ID_PARAM: publicExpertInfo.documentId},
        true);
  }

  Widget buildCallUnableShowAvailabilityButton(BuildContext context,
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return buildCallButtonHelper(
        Colors.purple[500]!,
        Colors.purple[900]!,
        'View ${publicExpertInfo.documentType.firstName}\'s Availability',
        Routes.UV_VIEW_EXPERT_AVAILABILITY_PAGE,
        {Routes.EXPERT_ID_PARAM: publicExpertInfo.documentId},
        true);
  }

  Widget buildCallActionButton(BuildContext context,
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    if (widget._currentUid == null) {
      return buildMakeAccountButton(context);
    }
    if ((widget._currentUid == widget._expertUid) ||
        !TimezoneUtil.isWithinTimeRange(
            publicExpertInfo.documentType.availability)) {
      return buildCallUnableShowAvailabilityButton(context, publicExpertInfo);
    }
    if (publicExpertInfo.documentType.inCall) {
      return buildCallUnableShowInCallStatus(context, publicExpertInfo);
    }
    return buildCallPreviewButton(context, publicExpertInfo);
  }

  Widget buildDescription(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return SizedBox(
      height: 100,
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 2.0,
        controller: _descriptionScrollController,
        child: SingleChildScrollView(
            controller: _descriptionScrollController,
            child: Text(
              publicExpertInfo.documentType.description,
              style: TextStyle(fontSize: 12),
            )),
      ),
    );
  }

  Widget buildAboutMeTitle(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return Text(
      "About Me",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }

  Widget buildEditButton(
      DocumentWrapper<PublicExpertInfo> publicExpertInfo, Function onEdit) {
    return IconButton(
      icon: const Icon(
        Icons.edit,
        size: 30,
        color: Colors.grey,
      ),
      onPressed: () {
        onEdit(publicExpertInfo);
      },
    );
  }

  Future openEditCategoryDialog(
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        title: Text("Edit your category of expertise"),
        content: _categorySelector,
      ),
    );
  }

  Future openEditDescriptionDialog(
          DocumentWrapper<PublicExpertInfo> publicExpertInfo) =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                actionsAlignment: MainAxisAlignment.spaceBetween,
                title: Text("Edit Description"),
                content: TextFormField(
                  autofocus: true,
                  maxLines: null,
                  controller: _textController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter a description",
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      final newDescription =
                          _textController.text.trim().replaceAll("\n", " ");
                      await updateProfileDescription(newDescription);
                      Navigator.of(context).pop();
                    },
                    child: Text("Save"),
                  ),
                ],
              ));

  Widget buildAboutMe(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  buildAboutMeTitle(publicExpertInfo),
                  Spacer(),
                  widget._isEditable
                      ? buildEditButton(
                          publicExpertInfo, openEditDescriptionDialog)
                      : SizedBox(),
                ],
              ),
              buildExpertProfileRating(publicExpertInfo),
              SizedBox(height: 10),
              buildDescription(publicExpertInfo),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReviewHeading() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            "Customer Reviews",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Spacer()
      ],
    );
  }

  Widget buildReviewList(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return Expanded(
      child: ExpertReviews(publicExpertInfo),
    );
  }

  Widget buildProfilePicture(
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    if (widget._isEditable) {
      return SizedBox(
        width: 150,
        height: 150,
        child: ProfilePicture(
            publicExpertInfo.documentType.profilePicUrl, onProfilePicSelection),
      );
    } else {
      return SizedBox(
        width: 150,
        height: 150,
        child: ProfilePicture(publicExpertInfo.documentType.profilePicUrl),
      );
    }
  }

  Widget buildProfileHeadingDescription(
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    final name = Text(
      publicExpertInfo.documentType.shortName(),
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final majorCategory = Expanded(
      child: Text(
        "${publicExpertInfo.documentType.majorCategory()}",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final minorCategory = Text(
      "Specializes in ${publicExpertInfo.documentType.minorCategory()}",
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    final editCategoryButton = widget._isEditable
        ? buildEditButton(publicExpertInfo, openEditCategoryDialog)
        : SizedBox();
    return Expanded(
      child: Column(
        children: [
          name,
          SizedBox(height: 10),
          Row(children: [
            majorCategory,
            editCategoryButton,
          ]),
          minorCategory,
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget buildProfileHeader(
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return Row(
      children: [
        SizedBox(
          width: 5,
        ),
        buildProfilePicture(publicExpertInfo),
        SizedBox(
          width: 10,
        ),
        buildProfileHeadingDescription(publicExpertInfo),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  void onProfilePicSelection(Uint8List profilePicBytes) async {
    // TODO, this crashes iOS 13 simulator via Rosetta.
    await onProfilePicUpload(pictureBytes: profilePicBytes);
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
          buildProfileHeader(publicExpertInfo),
          SizedBox(height: 10),
          buildAboutMe(publicExpertInfo),
          buildReviewHeading(),
          buildReviewList(publicExpertInfo),
          buildCallActionButton(context, publicExpertInfo),
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
      } else if (widget._isEditable) {
        return AppBar(
          title: Text("Expert Profile"),
          actions: [
            Row(
              children: [
                Text("Share"),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () async {
                    final url = await getShareableExpertProfileDynamicLink();
                    Share.share(url);
                    log('Shareable link: $url');
                  },
                ),
              ],
            ),
          ],
        );
      } else {
        return AppBar(
          title: Text("Expert Profile"),
        );
      }
    } else {
      return AppBar(
        title: Text("Loading..."),
      );
    }
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
