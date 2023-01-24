import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';

HttpsCallable getCallable(String functionName) {
  return FirebaseFunctions.instance.httpsCallable(functionName);
}

Future<void> onUserSignup(String firstName, String lastName, String email,
    String? profilePicUrl) async {
  Map<String, String> userData = {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
  };

  if (profilePicUrl != null) {
    userData['profilePicUrl'] = profilePicUrl;
  }
  await getCallable(CallableFunctions.USER_SIGNUP).call(userData);
}

Future<String> onSubmitReview(
    {required String reviewedUid,
    required String reviewText,
    required double reviewRating}) async {
  Map<String, dynamic> review = {
    'reviewedUid': reviewedUid,
    'reviewText': reviewText,
    'reviewRating': reviewRating,
  };
  final result =
      await getCallable(CallableFunctions.SUBMIT_REVIEW).call(review);
  return result.data["message"];
}

Future<void> onProfilePicUpload({required Uint8List pictureBytes}) async {
  Map<String, Uint8List> picture = {
    'pictureBytes': pictureBytes,
  };
  await getCallable(CallableFunctions.UPDATE_PROFILE_PIC).call(picture);
}

Future<String> lookupChatroomId(String otherUid) async {
  Map<String, dynamic> chatroomQuery = {
    'otherUid': otherUid,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.CHATROOM_LOOKUP).call(chatroomQuery);

  final chatroomId = result.data;
  return chatroomId;
}

Future<void> updateProfileDescription(String newDescription) async {
  Map<String, dynamic> chatroomQuery = {
    'description': newDescription,
  };
  await getCallable(CallableFunctions.UPDATE_PROFILE_DESCRIPTION)
      .call(chatroomQuery);
}

class UpdateExpertRateResult {
  final bool success;
  final String message;

  UpdateExpertRateResult({required this.success, required this.message});
}

Future<UpdateExpertRateResult> updateExpertRate(
    {required int centsPerMinute, required int centsStartCall}) async {
  Map<String, dynamic> updateQuery = {
    'centsStartCall': centsStartCall,
    'centsPerMinute': centsPerMinute,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.UPDATE_EXPERT_RATE).call(updateQuery);

  bool success = result.data['success'];
  String message = result.data['message'];

  return UpdateExpertRateResult(success: success, message: message);
}
