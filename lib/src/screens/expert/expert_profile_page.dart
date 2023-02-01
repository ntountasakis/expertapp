import 'dart:typed_data';

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/profile/star_rating.dart';
import 'package:expertapp/src/profile/expert/expert_reviews.dart';
import 'package:expertapp/src/profile/text_rating.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

class ExpertProfilePage extends StatefulWidget {
  final String _expertUid;
  final bool _isEditable;

  ExpertProfilePage(this._expertUid, this._isEditable);

  @override
  State<ExpertProfilePage> createState() => _ExpertProfilePageState();
}

class _ExpertProfilePageState extends State<ExpertProfilePage> {
  final _descriptionScrollController = ScrollController();
  late TextEditingController _textController;
  String _textControllerText = "Loading...";

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

  Widget buildCallPreviewButton(BuildContext context,
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      backgroundColor: Colors.green[500],
      elevation: 4.0,
      shadowColor: Colors.green[900],
    );
    return Row(
      children: [
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
              style: style,
              onPressed: () async {
                context.pushNamed(Routes.EXPERT_CALL_PREVIEW_PAGE, params: {
                  Routes.EXPERT_ID_PARAM: publicExpertInfo.documentId
                });
              },
              child: Text('Call ${publicExpertInfo.documentType.firstName}')),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget buildRating(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return Row(
      children: [
        Flexible(
            flex: 20,
            child: StarRating(
                publicExpertInfo.documentType.getAverageReviewRating(), 25.0)),
        Spacer(flex: 1),
        Flexible(
            flex: 20,
            child: TextRating(
                publicExpertInfo.documentType.getAverageReviewRating(), 18.0))
      ],
    );
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

  Widget buildAboutMeName(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return Text(
      publicExpertInfo.documentType.fullName(),
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }

  Widget buildEditButton(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return IconButton(
      icon: const Icon(
        Icons.edit,
        size: 30,
        color: Colors.grey,
      ),
      onPressed: () {
        openEditDescriptionDialog(publicExpertInfo);
      },
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
                  buildAboutMeName(publicExpertInfo),
                  Spacer(),
                  widget._isEditable
                      ? buildEditButton(publicExpertInfo)
                      : SizedBox(),
                ],
              ),
              buildRating(publicExpertInfo),
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
        width: 200,
        height: 200,
        child: ProfilePicture(
            publicExpertInfo.documentType.profilePicUrl, onProfilePicSelection),
      );
    } else {
      return SizedBox(
        width: 200,
        height: 200,
        child: ProfilePicture(publicExpertInfo.documentType.profilePicUrl),
      );
    }
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
          buildProfilePicture(publicExpertInfo),
          SizedBox(height: 10),
          buildCallPreviewButton(context, publicExpertInfo),
          buildAboutMe(publicExpertInfo),
          buildReviewHeading(),
          buildReviewList(publicExpertInfo),
        ],
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  AppBar buildAppbar(
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      return AppBar(
        title: Text(snapshot.data!.documentType.fullName()),
      );
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
