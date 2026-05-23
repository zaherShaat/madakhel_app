import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/auth/auth_service.dart';
import '../data/auth/auth_storage.dart';
import '../model/auth_user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _service;
  late final AuthUserStorage _storage;
  final Completer<void> _readyCompleter = Completer<void>();

  AuthViewModel(this._service) {
    _initialize();
  }

  StreamSubscription<User?>? _sub;
  AuthUser? _user;
  Object? _lastError;
  bool _busy = false;
  bool _initialized = false;

  AuthUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get ready => _initialized;
  bool get busy => _busy;
  Object? get lastError => _lastError;

  Future<void> _initialize() async {
    _storage = await AuthUserStorage.instance();
    _sub = _service.authStateChanges().listen(_handleAuthState);
    await _handleAuthState(_service.currentUser);
  }

  Future<void> _handleAuthState(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      await _storage.clearAuthUser();
    } else {
      final authUser = AuthUser.fromFirebase(firebaseUser);
      _user = authUser;
      await _storage.saveAuthUser(authUser);
    }

    _initialized = true;
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
    notifyListeners();
  }

  Future<void> ensureReady() => _readyCompleter.future;

  Future<AuthUser?> signInWithGoogle() async {
    await ensureReady();
    _setBusy(true);
    try {
      final authUser = await _service.signInWithGoogleUser();
      _user = authUser;
      await _storage.saveAuthUser(authUser);
      notifyListeners();
      return authUser;
    } on FirebaseAuthException catch (e) {
      debugPrint("$e >>> error g Auth");
      rethrow; // let UI handle Firebase errors
    } catch (e) {
      debugPrint("$e >>> error g Auth catch");
      throw Exception('فشل تسجيل الدخول عبر Google');
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() async {
    await ensureReady();
    _setBusy(true);
    try {
      _lastError = null;
      await _service.signOut();
      await _storage.clearAuthUser();
    } catch (e) {
      _lastError = e;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }
/// Let provider announce busy(loading state)
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
