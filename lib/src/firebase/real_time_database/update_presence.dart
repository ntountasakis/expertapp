import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class PresenceFirestore {
  final String presence;
  final FieldValue lastChanged;

  PresenceFirestore({required this.presence, required this.lastChanged});

  Map<String, dynamic> toJson() {
    return {
      'presence': presence,
      'lastChanged': lastChanged,
    };
  }
}

class PresenceRTDB {
  final String presence;
  final Map<dynamic, dynamic> lastChanged;

  PresenceRTDB({required this.presence, required this.lastChanged});

  Map<String, dynamic> toJson() {
    return {
      'presence': presence,
      'lastChanged': lastChanged,
    };
  }
}

final isOfflineForRTDB =
    PresenceRTDB(presence: 'offline', lastChanged: ServerValue.timestamp);

final isOnlineForRTDB =
    PresenceRTDB(presence: 'online', lastChanged: ServerValue.timestamp);

final isOfflineForFirestore = PresenceFirestore(
    presence: 'offline', lastChanged: FieldValue.serverTimestamp());

final isOnlineForFirestore = PresenceFirestore(
    presence: 'online', lastChanged: FieldValue.serverTimestamp());

StreamSubscription keepPresenceUpdated({required String currentUserId}) {
  final userStatusRTDBRef =
      FirebaseDatabase.instance.ref("/status/${currentUserId}");
  final userStatusFirestoreRef =
      FirebaseFirestore.instance.doc("/status/${currentUserId}");
  final connectedRTDBRef = FirebaseDatabase.instance.ref(".info/connected");

  return connectedRTDBRef.onValue.listen((event) async {
    if (!event.snapshot.exists) {
      await userStatusFirestoreRef.set(isOfflineForFirestore.toJson());
      return;
    }

    userStatusRTDBRef
        .onDisconnect()
        .set(isOfflineForRTDB.toJson())
        .then((value) async {
      await userStatusRTDBRef.set(isOnlineForRTDB.toJson());
      await userStatusFirestoreRef.set(isOnlineForFirestore.toJson());
    });
  });
}

Future<void> markPresenceOffline({required String currentUserId}) async {
  final userStatusRTDBRef =
      FirebaseDatabase.instance.ref("/status/${currentUserId}");
  await userStatusRTDBRef.set(isOfflineForRTDB.toJson());
}
