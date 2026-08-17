import 'package:flutter/material.dart';
import 'package:madakhel_app/data/repositories/income_type_repository.dart';
import 'package:madakhel_app/view_model/auth_view_model.dart';

// class SplashResult {
//   final bool signedIn;

//   const SplashResult({required this.signedIn});
// }

class SplashViewModel extends ChangeNotifier {
  final AuthViewModel _auth;
  final IncomeTypeRepository _incomeSources;
  SplashViewModel(this._auth, this._incomeSources);

  Future<bool> load() async {
    await _auth.ensureReady();
    await _incomeSources.getAll();
    await _incomeSources.getAll();
    return _auth.isSignedIn;
  }
}
