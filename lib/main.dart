<<<<<<< HEAD
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




=======
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sports Event App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: LoginScreen(),
    );
  }
}
>>>>>>> d2f32196e0c188ffd60e4aa6ca184e4050f4c737
