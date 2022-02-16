import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';

class DatabaseUtil {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  static Future<void> put(String aPath, Map<String, dynamic> aEntry) async {
    final DatabaseReference ref = _database.child(aPath);
    return ref.set(aEntry);
  }

  static Future<Map<String, dynamic>?> get(String aPath) async {
    DatabaseReference _database = FirebaseDatabase.instance.ref();
    try {
      final DatabaseReference ref = _database.child(aPath);
      return ref.get().then((event) {
        return event.value != null
            ? new Map<String, dynamic>.from(
                event.value as Map<dynamic, dynamic>)
            : null;
      });
    } catch (e) {
      log('Exception getting $aPath from Database: Error: $e');
      return null;
    }
  }

  static Stream<List<Map<String, dynamic>>> getEntryStream(String aPath) {
    DatabaseReference _database = FirebaseDatabase.instance.ref();
    final Stream<DatabaseEvent> databaseStream = _database.child(aPath).onValue;
    return databaseStream.map((DatabaseEvent event) {
      List<Map<String, dynamic>> entries = [];
      if (event.snapshot.value != null) {
        final recordMaps = Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);

        recordMaps.forEach((key, value) {
          final nextRecord = new Map<String, dynamic>();
          nextRecord[key] = value;
          entries.add(nextRecord);
        });
      }
      return entries;
    });
  }
}
