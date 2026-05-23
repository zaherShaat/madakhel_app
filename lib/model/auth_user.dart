import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final String providerId;
  final bool isAnonymous;

  AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.emailVerified,
    required this.providerId,
    required this.isAnonymous,
  });

  factory AuthUser.fromFirebase(User user) {
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'user'; // default to 'user' if no provider data available

    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      providerId: providerId,
      isAnonymous: user.isAnonymous,
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      emailVerified: json['emailVerified'] as bool,
      providerId: json['providerId'] as String,
      isAnonymous: json['isAnonymous'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'providerId': providerId,
      'isAnonymous': isAnonymous,
    };
  }
}
