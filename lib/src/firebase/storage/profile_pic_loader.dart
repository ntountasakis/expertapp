import 'package:expertapp/src/firebase/storage/storage_paths.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePicLoader {
  final _storage = FirebaseStorage.instance;

  Future<String> getProfilePicURL() async {
    final profilePicRef = _storage
        .ref()
        .child(StoragePaths.PROFILE_PICS)
        .child('man-profile.jpg');

    return await profilePicRef.getDownloadURL();
  }
}
