import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:madakhel_app/data/auth/auth_storage.dart';

import '../../model/auth_user.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _auth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  Stream<AuthUser?> authUserChanges() => _auth.authStateChanges().map(
    (user) => user == null ? null : AuthUser.fromFirebase(user),
  );

  User? get currentUser => _auth.currentUser;
  AuthUser? get currentAuthUser => _auth.currentUser == null
      ? null
      : AuthUser.fromFirebase(_auth.currentUser!);

  Future<UserCredential> _signInWithGoogle() async {
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result;
  }

  Future<AuthUser> signInWithGoogleUser() async {
    final result = await _signInWithGoogle();
    final user = result.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'NO_USER',
        message: 'Google sign-in completed without a Firebase user.',
      );
    }
    return AuthUser.fromFirebase(user);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
