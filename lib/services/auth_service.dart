import 'package:firebase_auth/firebase_auth.dart';

// This class wraps Firebase Auth methods so our UI code stays clean.
// All authentication operations are handled here in one place.
class AuthService {
  // FirebaseAuth.instance gives us access to the Firebase Auth SDK.
  // We store it in a private variable (prefixed with _) so it cannot
  // be accessed from outside this class.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ─── SIGN UP ─────────────────────────────────────────────────────
  // Future<UserCredential?> means this is async and returns either
  // a UserCredential (on success) or null (on failure).
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException contains specific error codes like
      // "email-already-in-use" or "weak-password"
      print('Sign-up error: ${e.message}');
      return null; // Return null to indicate failure
    }
  }

  // ─── LOGIN ───────────────────────────────────────────────────────
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.message}');
      return null;
    }
  }

  // ─── LOGOUT ──────────────────────────────────────────────────────
  // This is a simple one-liner. The => syntax is a shorthand for
  // a function that immediately returns an expression.
  Future<void> logout() => _auth.signOut();
  // ─── GET CURRENT USER ─────────────────────────────────────────────
  // Returns the currently logged-in User, or null if no one is logged in.
  // This is a getter (not a method call), so you access it as a property:
  // authService.currentUser (not authService.currentUser())
  User? get currentUser => _auth.currentUser;
  // ─── AUTH STATE STREAM ────────────────────────────────────────────
  // Returns a Stream that emits User? whenever the auth state changes.
  // This is what we use in StreamBuilder in main.dart.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}