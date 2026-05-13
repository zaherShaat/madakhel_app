import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../model/auth_user.dart';

class AuthUserStorage {
  static const _authUserKey = 'auth_user_data';
  static AuthUserStorage? _instance;

  final SharedPreferences _preferences;

  AuthUserStorage._(this._preferences);

  static Future<AuthUserStorage> instance() async {
    if (_instance != null) {
      return _instance!;
    }

    final preferences = await SharedPreferences.getInstance();
    _instance = AuthUserStorage._(preferences);
    return _instance!;
  }

  AuthUser? get storedAuthUser {
    final jsonString = _preferences.getString(_authUserKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthUser.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAuthUser(AuthUser user) async {
    await _preferences.setString(_authUserKey, jsonEncode(user.toJson()));
  }

  Future<void> clearAuthUser() async {
    await _preferences.remove(_authUserKey);
  }
}
