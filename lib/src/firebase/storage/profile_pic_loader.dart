import 'package:expertapp/src/firebase/database/database_paths.dart';
import 'package:expertapp/src/firebase/storage/storage_paths.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePicLoader {
  final _storage = FirebaseStorage.instance;
  final _database = FirebaseDatabase.instance.ref();

  Future<String> getProfilePicURL(String uid) async {
    final databasePicRef =
        _database.child(DatabasePaths.PROFILE_PIC_FOR_EXPERT(uid));

    return databasePicRef.get().then((snapshot) async {
      if (snapshot.value != null) {
        final filename = snapshot.value as String;
        final imageRef =
            _storage.ref().child(StoragePaths.PROFILE_PICS).child(filename);
        return await imageRef.getDownloadURL();
      }
      final defaultPicRef =
          _storage.ref().child(StoragePaths.DEFAULT_PROFILE_PIC);
      return await defaultPicRef.getDownloadURL();
    });
  }
}
