import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';
import 'package:flutter/material.dart';

Future<List<String>> getMajorExpertCategories() async {
  final data = await FirebaseFirestore.instance
      .collection(CollectionPaths.EXPERT_CATEGORIES)
      .get();

  final List<String> majorCategories = [];
  data.docs.forEach((element) {
    majorCategories.add(element.id);
  });
  return majorCategories;
}

Future<List<String>> getMinorExpertCategories(String majorCategory) async {
  final data = await FirebaseFirestore.instance
      .collection(CollectionPaths.EXPERT_CATEGORIES)
      .doc(majorCategory)
      .get();

  if (data.data() == null) {
    return [];
  }

  final List<String> minorCategories = [];
  data.data()!.forEach((key, value) {
    minorCategories.add(key);
  });
  return minorCategories;
}

class ExpertCategorySelector extends StatefulWidget {
  final String uid;
  final VoidCallback onComplete;
  final bool fromSignUpFlow;
  ExpertCategorySelector(
      {required this.uid,
      required this.onComplete,
      required this.fromSignUpFlow});

  @override
  State<ExpertCategorySelector> createState() => _ExpertCategorySelectorState();
}

class _ExpertCategorySelectorState extends State<ExpertCategorySelector> {
  String? theSelectedMajorCategory;
  String? theSelectedMinorCategory;

  Future<void> onChangedMajorCategory(String aNewMajorCategory) async {
    log("Changed major category to $aNewMajorCategory");
    final defaultMinor = (await getMinorExpertCategories(aNewMajorCategory))[0];
    setState(() {
      theSelectedMajorCategory = aNewMajorCategory;
      theSelectedMinorCategory = defaultMinor;
    });
  }

  void onChangedMinorCategory(String aNewMinorCategory) {
    log("Changed minor category to $aNewMinorCategory");
    setState(() {
      theSelectedMinorCategory = aNewMinorCategory;
    });
  }

  Future<String> effectiveMinorCategory(
      PublicExpertInfo info, String effectiveMajorCategory) async {
    if (theSelectedMinorCategory != null) {
      return theSelectedMinorCategory!;
    }
    final categories = await getMinorExpertCategories(effectiveMajorCategory);
    if (categories.length > 0) {
      return categories[0];
    }
    return "";
  }

  Future<String> effectiveMajorCategory(PublicExpertInfo info) async {
    if (theSelectedMajorCategory != null) {
      return theSelectedMajorCategory!;
    } else if (info.majorExpertCategory != "") {
      return info.majorExpertCategory;
    }
    final categories = await getMajorExpertCategories();
    if (categories.length > 0) {
      return categories[0];
    }
    return "";
  }

  Widget buildSubmitButton(PublicExpertInfo info) {
    final ButtonStyle buttonStyle =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return ElevatedButton(
        style: buttonStyle,
        onPressed: () async {
          String nextMajorCategory = await effectiveMajorCategory(info);
          String nextMinorCategory =
              await effectiveMinorCategory(info, nextMajorCategory);
          final result = await updateExpertCategory(
              newMajorCategory: nextMajorCategory,
              newMinorCategory: nextMinorCategory,
              fromSignUpFlow: widget.fromSignUpFlow);
          setState(() {
            theSelectedMajorCategory = null;
            theSelectedMinorCategory = null;
          });
          if (result.success) {
            widget.onComplete();
          }
          Navigator.of(context).pop();
        },
        child: Text("Submit"));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentWrapper<PublicExpertInfo>?>(
        stream: PublicExpertInfo.getStreamForUser(
            uid: widget.uid, fromSignUpFlow: widget.fromSignUpFlow),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?>
                expertInfoSnapshot) {
          if (expertInfoSnapshot.hasData) {
            final expertInfo = expertInfoSnapshot.data!.documentType;
            List<Future> futureDropdowns = [
              buildDropdown(
                  "Select broad area of expertise",
                  effectiveMajorCategory(expertInfo),
                  getMajorExpertCategories(),
                  onChangedMajorCategory),
              buildMinorDropdown(expertInfo, "Select expertise specialization",
                  onChangedMinorCategory)
            ];
            return FutureBuilder<List<dynamic>>(
                future: Future.wait(futureDropdowns),
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> categorySnapshot) {
                  if (categorySnapshot.hasData) {
                    final majorDropdown =
                        categorySnapshot.data![0] as DropdownButtonFormField;
                    final minorDropdown =
                        categorySnapshot.data![1] as DropdownButtonFormField;
                    final contents = Column(
                      children: [
                        majorDropdown,
                        minorDropdown,
                        Spacer(),
                        buildSubmitButton(expertInfo),
                      ],
                    );

                    return SizedBox(
                      height: 200,
                      child: contents,
                    );
                  }
                  return SizedBox();
                });
          }
          return SizedBox();
        });
  }

  Future<Widget> buildMinorDropdown(
      PublicExpertInfo info, String aKey, Function(String) onChanged) async {
    final effectiveMajor = await effectiveMajorCategory(info);
    final minorCategory = effectiveMinorCategory(info, effectiveMajor);
    return buildDropdown(aKey, minorCategory,
        getMinorExpertCategories(effectiveMajor), onChanged);
  }

  Future<DropdownButtonFormField> buildDropdown(
      String aKey,
      Future<String> initialValue,
      Future<List<String>> aCategoryFuture,
      Function(String) onChanged) async {
    final categories = await aCategoryFuture;
    return DropdownButtonFormField(
      decoration: InputDecoration(labelText: aKey),
      key: Key(aKey),
      value: await initialValue,
      items: categories
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
          .toList(),
      onChanged: ((value) {
        onChanged(value);
      }),
    );
  }
}
