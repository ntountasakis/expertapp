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

Future<String> onProfilePicUpload({required Uint8List pictureBytes}) async {
  Map<String, Uint8List> picture = {
    'pictureBytes': pictureBytes,
  };
  HttpsCallableResult result =
      await getCallable(CallableFunctions.UPDATE_PROFILE_PIC).call(picture);

  final newProfilePicUrl = result.data['url'];
  return newProfilePicUrl;
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

Future<int> lookupBalancedOwedCents() async {
  HttpsCallableResult result =
      await getCallable(CallableFunctions.CHECK_OUTSTANDING_BALANCE).call();

  return result.data['owedBalanceCents'];
}

class OutstandingBalanceDetails {
  final int balanceOwedCents;
  final String customerId;
  final String clientSecret;
  final String paymentStatusId;
  final String ephemeralKey;

  OutstandingBalanceDetails(this.balanceOwedCents, this.customerId,
      this.clientSecret, this.paymentStatusId, this.ephemeralKey);

  bool hasOutstandingBalance() {
    return balanceOwedCents != 0;
  }
}

Future<OutstandingBalanceDetails> getInfoToPayOutstandingBalance() async {
  HttpsCallableResult result =
      await getCallable(CallableFunctions.PAY_OUTSTANDING_BALANCE).call();

  return OutstandingBalanceDetails(
      result.data['owedBalanceCents'],
      result.data['stripeCustomerId'],
      result.data['clientSecret'],
      result.data['paymentStatusId'],
      result.data['ephemeralKey']);
}
