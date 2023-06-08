import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget buildCallButtonHelper(
    BuildContext context,
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
                context.pushNamed(routeName, pathParameters: params);
              } else {
                context.pushReplacementNamed(routeName, pathParameters: params);
              }
            },
            child: Text(buttonText)),
      ),
      SizedBox(width: 10),
    ],
  );
}

Widget buildMakeAccountButton(BuildContext context) {
  return buildCallButtonHelper(context, Colors.green[500]!, Colors.green[900]!,
      'Click to sign in to call this guide', Routes.SIGN_IN_PAGE, {}, false);
}

Widget buildCallPreviewButton(
    BuildContext context, DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
  return buildCallButtonHelper(
      context,
      Colors.green[500]!,
      Colors.green[900]!,
      'Call ${publicExpertInfo.documentType.firstName}',
      Routes.UV_EXPERT_CALL_PREVIEW_PAGE,
      {Routes.EXPERT_ID_PARAM: publicExpertInfo.documentId},
      true);
}

Widget buildCallUnableShowInCallStatus(
    BuildContext context, DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
  return buildCallButtonHelper(
      context,
      Colors.red[500]!,
      Colors.red[900]!,
      'They are currently in another call. Please come back later.',
      Routes.UV_VIEW_EXPERT_AVAILABILITY_PAGE,
      {Routes.EXPERT_ID_PARAM: publicExpertInfo.documentId},
      true);
}

Widget buildCallUnableShowAvailabilityButton(
    BuildContext context, DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
  return buildCallButtonHelper(
      context,
      Colors.purple[500]!,
      Colors.purple[900]!,
      'View ${publicExpertInfo.documentType.firstName}\'s availability',
      Routes.UV_VIEW_EXPERT_AVAILABILITY_PAGE,
      {Routes.EXPERT_ID_PARAM: publicExpertInfo.documentId},
      true);
}

Widget buildExpertProfileCallActionButton(
    {required BuildContext context,
    required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    required String? currentUserUid}) {
  if (currentUserUid == publicExpertInfo.documentId ||
      !publicExpertInfo.documentType.isAvailable()) {
    return buildCallUnableShowAvailabilityButton(context, publicExpertInfo);
  }
  if (publicExpertInfo.documentType.inCall) {
    return buildCallUnableShowInCallStatus(context, publicExpertInfo);
  }
  if (currentUserUid == null) {
    return buildMakeAccountButton(context);
  }
  return buildCallPreviewButton(context, publicExpertInfo);
}
