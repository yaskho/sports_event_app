import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<QuerySnapshot>? _eventsSubscription;

  NotificationService() {
    _initLocalNotifications();
    _requestPermission();
    _listenToEvents();
  }

  /// Initialize local notifications plugin
  void _initLocalNotifications() {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    _localNotifications.initialize(settings);
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  /// Show a local notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('event_channel', 'Event Notifications',
            channelDescription: 'Notifications about events you joined',
            importance: Importance.max,
            priority: Priority.high);

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );
  }

  /// Listen to changes in events where the current user is a participant
  void _listenToEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Listen to all events
    _eventsSubscription = _firestore
        .collection('events')
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        final data = docChange.doc.data();
        if (data == null) continue;

        final participants = List<String>.from(data['participants'] ?? []);
        final maxPlayers = data['maxPlayers'] ?? 0;
        final missingPlayers = (maxPlayers - participants.length).clamp(0, maxPlayers);

        final eventName = data['eventName'] ?? 'Unknown Event';

        switch (docChange.type) {
          case DocumentChangeType.added:
            // do nothing for newly created events
            break;

          case DocumentChangeType.modified:
            // Event updated
            if (participants.contains(user.uid) && missingPlayers == 0) {
              _showNotification(
                  "Event Full",
                  "The event '$eventName' you joined is now full.");
            }
            break;

          case DocumentChangeType.removed:
            // Event deleted
            if (participants.contains(user.uid)) {
              _showNotification(
                  "Event Deleted",
                  "The event '$eventName' you joined has been deleted.");
            }
            break;
        }
      }
    });
  }

  /// Dispose the listener when app closes
  void dispose() {
    _eventsSubscription?.cancel();
  }
}
