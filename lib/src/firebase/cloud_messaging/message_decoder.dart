import 'package:expertapp/src/firebase/cloud_messaging/messages/call_join_request.dart';

class MessageDecoder {
  static CallJoinRequest callJoinRequestFromJson(Map<String, dynamic> json) {
    final keys = ['callerUid', 'calledUid'];

    for (String k in keys) {
      if (!json.containsKey(k)) {
        throw new Exception(
            'Cannot decode FCM CallJoinRequest. Key not found: ${k}');
      }
    }
    return CallJoinRequest(callerUid: json['callerUid'], calledUid: json['calledUid']);
  }
}
