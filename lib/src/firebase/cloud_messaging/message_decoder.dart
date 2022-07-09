import 'package:expertapp/src/firebase/cloud_messaging/messages/call_join_request.dart';

class MessageDecoder {
  static CallJoinRequestTokenPayload callJoinRequestFromJson(
      Map<String, dynamic> json) {
    final keys = ['callerUid', 'calledUid', 'callTransactionId'];

    for (String k in keys) {
      if (!json.containsKey(k)) {
        throw new Exception(
            'Cannot decode FCM CallJoinRequest. Key not found: ${k}');
      }
    }
    return CallJoinRequestTokenPayload(
        callerUid: json['callerUid'],
        calledUid: json['calledUid'], callTransactionId: json['callTransactionId']);
  }
}
