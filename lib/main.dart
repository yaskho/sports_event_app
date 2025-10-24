import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb && !Platform.isLinux) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔔 Notification reçue en background: ${message.notification?.title}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && !Platform.isLinux) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Event App',
      debugShowCheckedModeBanner: false,
      home: NotificationTestPage(),
    );
  }
}

class NotificationTestPage extends StatefulWidget {
  @override
  _NotificationTestPageState createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  String? token;

  @override
  void initState() {
    super.initState();

    // Firebase seulement si pas Linux et pas Web
    if (!kIsWeb && !Platform.isLinux) {
      FirebaseMessaging.instance.requestPermission();

      FirebaseMessaging.instance.getToken().then((t) {
        setState(() {
          token = t;
        });
        print("Device token: $token");
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Notification reçue en foreground: ${message.notification?.title}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayText;
    if (kIsWeb) {
      displayText = 'Running on Web';
    } else if (Platform.isLinux) {
      displayText = 'Running on Linux';
    } else if (token != null) {
      displayText = 'Device Token:\n$token';
    } else {
      displayText = 'Loading token...';
    }

    return Scaffold(
      appBar: AppBar(title: Text('Sports Event App')),
      body: Center(
        child: Text(displayText),
      ),
    );
  }
}
