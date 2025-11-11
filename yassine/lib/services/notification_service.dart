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
  StreamSubscription<User?>? _authSubscription;

  NotificationService() {
    _initLocalNotifications();
    _requestPermission();
    _listenToAuthAndEvents();
  }

  
  void _initLocalNotifications() {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    _localNotifications.initialize(settings);
  }

  
  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('event_channel', 'Event Notifications',
            channelDescription:
                'Notifications about events you joined or created',
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

  
  void _listenToAuthAndEvents() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _eventsSubscription?.cancel();

      if (user == null) {
        return; 
      }

      _listenToEvents(user);

      
      await _notifyCreatorOfAlreadyFullEvents(user);

      
      await _checkDeletedJoinedEvents(user);
    });
  }

  
  Future<void> _notifyCreatorOfAlreadyFullEvents(User user) async {
    final snapshot = await _firestore
        .collection('events')
        .where('organizerId', isEqualTo: user.uid)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants'] ?? []);
      final maxPlayers = data['maxPlayers'] ?? 0;
      final missingPlayers =
          (maxPlayers - participants.length).clamp(0, maxPlayers);

      if (missingPlayers == 0) {
        final eventName = data['eventName'] ?? 'Your Event';
        _showNotification(
          "Your Event Is Full!",
          "Your event '$eventName' already has all players.",
        );
      }
    }
  }

  
  Future<void> _checkDeletedJoinedEvents(User user) async {
    
    
    
    final existingSnapshot = await _firestore.collection('events').get();
    final existingEventIds = existingSnapshot.docs.map((d) => d.id).toSet();

    
    final joinedSnapshot = await _firestore
        .collection('events')
        .where('participants', arrayContains: user.uid)
        .get();

    
    for (var joinedDoc in joinedSnapshot.docs) {
      if (!existingEventIds.contains(joinedDoc.id)) {
        final eventName = joinedDoc['eventName'] ?? 'Unknown Event';
        _showNotification(
          "Event Cancelled",
          "The event '$eventName' you joined has been cancelled.",
        );
      }
    }
  }

  
  void _listenToEvents(User user) {
    _eventsSubscription = _firestore.collection('events').snapshots().listen(
      (snapshot) {
        for (var docChange in snapshot.docChanges) {
          final data = docChange.doc.data();
          if (data == null) continue;

          final participants = List<String>.from(data['participants'] ?? []);
          final maxPlayers = data['maxPlayers'] ?? 0;
          final missingPlayers =
              (maxPlayers - participants.length).clamp(0, maxPlayers);
          final eventName = data['eventName'] ?? 'Unknown Event';
          final organizerId = data['organizerId'];

          switch (docChange.type) {
            case DocumentChangeType.added:
              break;

            case DocumentChangeType.modified:
              
              if (participants.contains(user.uid) && missingPlayers == 0) {
                _showNotification(
                  "Event Full",
                  "The event '$eventName' you joined is now full.",
                );
              }

              
              if (organizerId == user.uid && missingPlayers == 0) {
                _showNotification(
                  "Your Event Is Full!",
                  "Your event '$eventName' now has all players.",
                );
              }
              break;

            case DocumentChangeType.removed:
              
              if (participants.contains(user.uid)) {
                _showNotification(
                  "Event Deleted",
                  "The event '$eventName' you joined has been deleted.",
                );
              }
              break;
          }
        }
      },
    );
  }

  
  void dispose() {
    _eventsSubscription?.cancel();
    _authSubscription?.cancel();
  }
}
