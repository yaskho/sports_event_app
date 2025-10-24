import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Sign Up
  Future<User?> signUp(String name, String email, String password) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = res.user;

      if (user != null) {
        // Save user in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'preferredSports': [],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Subscribe to notifications topic
        await _messaging.subscribeToTopic("allUsers");

        print(" User signed up: ${user.uid}");
      }

      return user;
    } catch (e) {
      print("❌ SignUp Error: $e");
      return null;
    }
  }

  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = res.user;

      if (user != null) {
        // Subscribe to notifications topic after login
        await _messaging.subscribeToTopic("allUsers");

        print("✅ User logged in: ${user.uid}");
      }

      return user;
    } catch (e) {
      print(" SignIn Error: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("User signed out");
    } catch (e) {
      print(" SignOut Error: $e");
    }
  }
}
