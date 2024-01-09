import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:flutter/material.dart';

Widget buildExpertProfileDescription({
  required ScrollController scrollController,
  required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
}) {
  return SizedBox(
    height: 100,
    child: Scrollbar(
      thumbVisibility: true,
      thickness: 2.0,
      controller: scrollController,
      child: SingleChildScrollView(
          controller: scrollController,
          child: Text(
            publicExpertInfo.documentType.description,
            style: TextStyle(fontSize: 12),
          )),
    ),
  );
}
