class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return res.user;
  }

  Future<User?> signIn(String email, String password) async {
    UserCredential res = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return res.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
