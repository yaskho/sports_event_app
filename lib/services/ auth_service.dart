import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Register new user
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required List<String> preferredSports,
  }) async {
    try {
      // Create account in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Create user document in Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'preferredSports': preferredSports,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // 🔹 Login existing user
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // 🔹 Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔹 Get current user
  User? get currentUser => _auth.currentUser;
}
