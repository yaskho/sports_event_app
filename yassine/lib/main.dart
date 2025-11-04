import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yassine_project/screens/create_event_screen.dart';
import 'package:yassine_project/screens/home_screen.dart';
import 'package:yassine_project/screens/profile_screen.dart';
import 'package:yassine_project/screens/register_screen.dart';
import 'package:yassine_project/screens/view_events_screen.dart';
import 'package:yassine_project/services/notification_service.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Start notification service
  NotificationService notificationService = NotificationService();
  runApp(MyApp());

  // Optionally dispose it on app close
  // notificationService.dispose(); 
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