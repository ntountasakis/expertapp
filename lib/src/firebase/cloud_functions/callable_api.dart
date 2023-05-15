import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_availability.dart';
import 'package:expertapp/src/version/app_version.dart';

class UpdateResult {
  final bool success;
  final String message;

  UpdateResult({required this.success, required this.message});
}

HttpsCallable getCallable(String functionName) {
  return FirebaseFunctions.instance.httpsCallable(functionName);
}

Future<UpdateResult> onAccountDelete() async {
  Map<String, String> query = {
    'version': AppVersion.version,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.DELETE_USER).call(query);

  bool success = result.data['success'];
  String message = result.data['message'];

  return UpdateResult(success: success, message: message);
}

Future<void> onUserSignup(String firstName, String lastName, String email,
    String? profilePicUrl) async {
  Map<String, String> userData = {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'version': AppVersion.version,
  };

  if (profilePicUrl != null) {
    userData['profilePicUrl'] = profilePicUrl;
  }
  await getCallable(CallableFunctions.REGULAR_USER_SIGNUP).call(userData);
}

Future<String> onSubmitReview(
    {required String reviewedUid,
    required String reviewText,
    required double reviewRating}) async {
  Map<String, dynamic> review = {
    'reviewedUid': reviewedUid,
    'reviewText': reviewText,
    'reviewRating': reviewRating,
    'version': AppVersion.version,
  };
  final result =
      await getCallable(CallableFunctions.SUBMIT_REVIEW).call(review);
  return result.data["message"];
}

Future<String> getDefaultProfilePicUrl() async {
  Map<String, dynamic> query = {
    'version': AppVersion.version,
  };
  final result =
      await getCallable(CallableFunctions.GET_DEFAULT_PROFILE_PIC_URL)
          .call(query);
  return result.data;
}

Future<double> getPlatformPercentFee() async {
  Map<String, dynamic> query = {
    'version': AppVersion.version,
  };
  final result =
      await getCallable(CallableFunctions.GET_PLATFORM_FEE).call(query);
  return result.data['platformPercentFee'].toDouble();
}

Future<void> onProfilePicUpload(
    {required Uint8List pictureBytes, required bool fromSignUpFlow}) async {
  Map<String, dynamic> picture = {
    'pictureBytes': pictureBytes,
    'fromSignUpFlow': fromSignUpFlow,
    'version': AppVersion.version,
  };
  await getCallable(CallableFunctions.UPDATE_PROFILE_PIC).call(picture);
}

Future<String> lookupChatroomId(String otherUid) async {
  Map<String, dynamic> chatroomQuery = {
    'otherUid': otherUid,
    'version': AppVersion.version,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.CHATROOM_LOOKUP).call(chatroomQuery);

  final chatroomId = result.data;
  return chatroomId;
}

Future<UpdateResult> updateProfileDescription(
    String newDescription, bool fromSignUpFlow) async {
  Map<String, dynamic> chatroomQuery = {
    'description': newDescription,
    'fromSignUpFlow': fromSignUpFlow,
    'version': AppVersion.version,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.UPDATE_PROFILE_DESCRIPTION)
          .call(chatroomQuery);
  bool success = result.data['success'];
  String message = result.data['message'];

  return UpdateResult(success: success, message: message);
}

Future<UpdateResult> updateExpertRate(
    {required int centsPerMinute,
    required int centsStartCall,
    required bool fromSignUpFlow}) async {
  Map<String, dynamic> updateQuery = {
    'centsStartCall': centsStartCall,
    'centsPerMinute': centsPerMinute,
    'fromSignUpFlow': fromSignUpFlow,
    'version': AppVersion.version,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.UPDATE_EXPERT_RATE).call(updateQuery);

  bool success = result.data['success'];
  String message = result.data['message'];

  return UpdateResult(success: success, message: message);
}

Future<UpdateResult> updateExpertAvailability(
    ExpertAvailability availability, bool fromSignUpFlow) async {
  Map<String, dynamic> updateQuery = {
    'availability': availability.toJson(),
    'fromSignUpFlow': fromSignUpFlow,
    'version': AppVersion.version,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.UPDATE_EXPERT_AVAILABILITY)
          .call(updateQuery);

  bool success = result.data['success'];
  String message = result.data['message'];

  return UpdateResult(success: success, message: message);
}

class ChatroomPreview {
  final String otherUid;
  final String lastMessage;
  final String lastMessageSenderUid;
  final int lastMessageMillisecondsSinceEpochUtc;

  ChatroomPreview(
      {required this.otherUid,
      required this.lastMessage,
      required this.lastMessageSenderUid,
      required this.lastMessageMillisecondsSinceEpochUtc});
}

Future<List<ChatroomPreview>> getAllChatroomsForUser() async {
  Map<String, dynamic> query = {
    'version': AppVersion.version,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.GET_ALL_CHATROOM_PREVIEWS_FOR_USER)
          .call(query);
  final rawPreviews = result.data as List<Object?>;
  final chatroomPreviews = <ChatroomPreview>[];
  rawPreviews.forEach((elem) {
    final preview = elem as Map<Object?, Object?>;
    chatroomPreviews.add(ChatroomPreview(
        otherUid: preview['otherUid'] as String,
        lastMessage: preview['lastMessage'] as String,
        lastMessageSenderUid: preview['lastMessageSenderUid'] as String,
        lastMessageMillisecondsSinceEpochUtc:
            preview['lastMessageMillisecondsSinceEpochUtc'] as int));
  });
  return chatroomPreviews;
}

Future<String> getShareableExpertProfileDynamicLink(String expertUid) async {
  Map<String, dynamic> linkQuery = {
    'expertUid': expertUid,
    'version': AppVersion.version,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.GET_SHAREABLE_DYNAMIC_PROFILE_LINK)
          .call(linkQuery);
  final linkUrl = result.data;
  return linkUrl;
}

Future<UpdateResult> updateExpertCategory({
  required String newMajorCategory,
  required String newMinorCategory,
  required bool fromSignUpFlow,
}) async {
  Map<String, dynamic> updateCategoryQuery = {
    'newMajorCategory': newMajorCategory,
    'newMinorCategory': newMinorCategory,
    'fromSignUpFlow': fromSignUpFlow,
    'version': AppVersion.version,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.UPDATE_EXPERT_CATEGORY)
          .call(updateCategoryQuery);
  bool success = result.data['success'];
  String message = result.data['message'];

  return UpdateResult(success: success, message: message);
}

Future<UpdateResult> completeExpertSignUp() async {
  Map<String, dynamic> query = {
    'version': AppVersion.version,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.COMPLETE_EXPERT_SIGN_UP).call(query);
  bool success = result.data['success'];
  String message = result.data['message'];

  return UpdateResult(success: success, message: message);
}
