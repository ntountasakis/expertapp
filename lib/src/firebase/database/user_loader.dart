import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';

import 'models/user_id.dart';

class UserLoader {
  final _database = FirebaseDatabase.instance.ref();
  late final _userStream;

  UserLoader(String userPath) {
    _userStream = _database.child(userPath).onValue;
  }

  Stream<List<UserId>> getUserStream() {
    try {
      var mapStream = _userStream.map<List<UserId>>((event) {
        final userMaps = List<dynamic>.from(event.snapshot.value);
        final List<UserId> userList = [];
        userMaps.forEach((nextUser) {
          if (nextUser != null)
          {
            userList.add(UserId(nextUser['name'], nextUser['id']));
          }
        });
        return userList;
      });

      return mapStream;
    } catch (e) {
      log(e.toString());
    }
    throw NullThrownError();
  }
}
