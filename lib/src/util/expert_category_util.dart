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

  Future<String> effectiveMinorCategory(PublicExpertInfo info) async {
    if (theSelectedMinorCategory != null) {
      return theSelectedMinorCategory!;
    }
    if (theSelectedMajorCategory != null) {
      return (await getMinorExpertCategories(theSelectedMajorCategory!))[0];
    }
    return info.minorExpertCategory;
  }

  String effectiveMajorCategory(PublicExpertInfo info) {
    return theSelectedMajorCategory != null
        ? theSelectedMajorCategory!
        : info.majorExpertCategory;
  }

  Widget buildSubmitButton(PublicExpertInfo info) {
    final ButtonStyle buttonStyle =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return ElevatedButton(
        style: buttonStyle,
        onPressed: () async {
          if (theSelectedMajorCategory != null ||
              theSelectedMinorCategory != null) {
            String? nextMajorCategory = effectiveMajorCategory(info);
            String? nextMinorCategory = await effectiveMinorCategory(info);
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
          }
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
            return FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  buildDropdown(
                      "Select broad area of expertise",
                      effectiveMajorCategory(expertInfo),
                      getMajorExpertCategories(),
                      onChangedMajorCategory),
                  buildMinorDropdown(
                      expertInfo,
                      "Select expertise specialization",
                      onChangedMinorCategory),
                ]),
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
    final minorCategory = await effectiveMinorCategory(info);
    return buildDropdown(aKey, minorCategory,
        getMinorExpertCategories(effectiveMajorCategory(info)), onChanged);
  }

  Future<DropdownButtonFormField> buildDropdown(
      String aKey,
      String? initialValue,
      Future<List<String>> aCategoryFuture,
      Function(String) onChanged) async {
    final categories = await aCategoryFuture;
    return DropdownButtonFormField(
      decoration: InputDecoration(labelText: aKey),
      key: Key(aKey),
      value: initialValue,
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
