import 'dart:developer';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageUtil {
  static final _storage = FirebaseStorage.instance;

  static Future<String> getDownloadUrl(String path) async {
    return await _storage.ref().child(path).getDownloadURL();
  }

  static String getLocalhostUrlForStorageUrl(String url) {
    if (url.length > 5 && url.substring(0, 5) == 'https') {
      return url;
    }
    return 'http://' + localhostString() + ':' + url.split(':')[2];
  }
}
