import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/auth/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service;
  // final GoogleSignIn gAuthInstance = GoogleSignIn.instance;
  AuthController(this._service) {
    _sub = _service.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  StreamSubscription<User?>? _sub;
  User? _user;
  Object? _lastError;
  bool _busy = false;

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get busy => _busy;
  Object? get lastError => _lastError;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger Google auth flow
      return await _service.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      debugPrint("$e >>> error g Auth");
      rethrow; // let UI handle Firebase errors
    } catch (e) {
      debugPrint("$e >>> error g Auth catch");
      throw Exception('فشل تسجيل الدخول عبر Google');
    }
  }

  Future<void> signOut() async {
    _setBusy(true);
    try {
      _lastError = null;
      await _service.signOut();
    } catch (e) {
      _lastError = e;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool v) {
    if (_busy == v) return;
    _busy = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
