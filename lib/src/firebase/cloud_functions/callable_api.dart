import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';

HttpsCallable getCallable(String functionName) {
  return FirebaseFunctions.instance.httpsCallable(functionName);
}

Future<void> onUserSignup(
    String firstName, String lastName, String? profilePicUrl) async {
  Map<String, String> userData = {
    'firstName': firstName,
    'lastName': lastName,
  };

  if (profilePicUrl != null) {
    userData['profilePicUrl'] = profilePicUrl;
  }
  await getCallable(CallableFunctions.USER_SIGNUP).call(userData);
}

Future<void> onSubmitReview(
    {required String reviewedUid,
    required String reviewText,
    required double reviewRating}) async {
  Map<String, dynamic> review = {
    'reviewedUid': reviewedUid,
    'reviewText': reviewText,
    'reviewRating': reviewRating,
  };
  await getCallable(CallableFunctions.SUBMIT_REVIEW).call(review);
}

Future<String> onProfilePicUpload({required Uint8List pictureBytes}) async {
  Map<String, Uint8List> picture = {
    'pictureBytes': pictureBytes,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.UPDATE_PROFILE_PIC).call(picture);

  final newProfilePicUrl = result.data;
  return newProfilePicUrl;
}
