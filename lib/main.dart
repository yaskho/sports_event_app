import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permissions (iOS)
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Subscribe to topic "events"
  messaging.subscribeToTopic("events");

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notification jayet!');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
    });

    // Listen for messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped!');
      print('Event ID: ${message.data['eventId']}');

      // Navigate to Event Details (replace with your screen)
      // Navigator.pushNamed(context, '/eventDetails', arguments: message.data['eventId']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Event App',
      home: HomeScreen(),
      // Define routes for navigation
      // routes: { '/eventDetails': (context) => EventDetailsScreen() },
    );
  }
}

// Example HomeScreen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sports Event App')),
      body: Center(child: Text('Welcome to the Sports Event App!')),
    );
  }
}




