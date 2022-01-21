import 'package:expertapp/src/firebase/database/database_paths.dart';
import 'package:expertapp/src/firebase/database/models/user_id.dart';
import 'package:expertapp/src/firebase/storage/storage_paths.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePicLoader {
  final _storage = FirebaseStorage.instance;
  final _database = FirebaseDatabase.instance.ref();

  Future<String> getProfilePicURL(UserId userId) async {
    final databasePicRef =
        _database.child(DatabasePaths.PROFILE_PIC_FOR_EXPERT(userId));

    return databasePicRef.get().then((snapshot) async {
      final filename = snapshot.value as String;
      final imageRef =
          _storage.ref().child(StoragePaths.PROFILE_PICS).child(filename);
      return await imageRef.getDownloadURL();
    });
  }
}
