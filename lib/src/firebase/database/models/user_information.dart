import 'package:expertapp/src/firebase/database/database_paths.dart';
import 'package:expertapp/src/firebase/database/database_util.dart';

class UserInformation {
  final String uid;
  final String firstName;
  final String lastName;
  final String? profilePicUrl;

  UserInformation(this.uid, this.firstName, this.lastName, this.profilePicUrl);

  Future<void> put() async {
    await DatabaseUtil.put(_path(uid), _toRTDB());
  }

  static Future<UserInformation?> get(String uid) async {
    final userMap = await DatabaseUtil.get(DatabasePaths.USER_INFO + uid);
    if (userMap != null) {
      return UserInformation._fromRTDB(uid, userMap);
    }
    return null;
  }

  static Stream<List<UserInformation>> getStream() {
    final Stream<List<Map<String, dynamic>>> userStream =
        DatabaseUtil.getEntryStream(DatabasePaths.USER_INFO);
    return userStream.map((List<Map<String, dynamic>> event) {
      final userInfos = <UserInformation>[];
      event.forEach((userMaps) {
        userMaps.forEach((key, value) {
          final userInfoMap =
              Map<String, dynamic>.from(value as Map<dynamic, dynamic>);
          userInfos.add(_fromRTDB(key, userInfoMap));
        });
      });
      return userInfos;
    });
  }

  String _path(String aUserId) {
    return DatabasePaths.USER_INFO + aUserId;
  }

  Map<String, dynamic> _toRTDB() {
    var fieldsMap = {'firstName': firstName, 'lastName': lastName};
    if (profilePicUrl != null) {
      fieldsMap['profilePicUrl'] = profilePicUrl!;
    }
    return fieldsMap;
  }

  static UserInformation _fromRTDB(String uid, Map<String, dynamic> data) {
    String? profilePicUrl;
    if (data.containsKey('profilePicUrl')) {
      profilePicUrl = data['profilePicUrl'];
    }
    return UserInformation(
        uid, data['firstName'], data['lastName'], profilePicUrl);
  }
}
