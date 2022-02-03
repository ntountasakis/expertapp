import 'package:firebase_storage/firebase_storage.dart';

class StorageUtil {
  static final _storage = FirebaseStorage.instance;

  static Future<String> getDownloadUrl(String path) async {
    return _storage.ref().child(path).getDownloadURL();
  }

}