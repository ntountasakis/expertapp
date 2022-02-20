import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageUtil {
  static final _storage = FirebaseStorage.instance;

  static Future<String> getDownloadUrl(String path) async {
    return _storage.ref().child(path).getDownloadURL();
  }

  static Future<void> uploadFile(Uint8List rawBytes, String storagePath) async {
    try {
      await _storage.ref(storagePath).putData(rawBytes);
    } on FirebaseException {
      log('Exception uploading to $storagePath');
    }
  }

  static Future<void> deleteFile(String fileUrl) async {
    try {
      await _storage.refFromURL(fileUrl).delete();
    } on FirebaseException {
      log('Exception deleting $fileUrl');
    }
  }
}
