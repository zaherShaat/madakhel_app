import 'package:flutter/foundation.dart';
import 'package:madakhel_app/data/connectivity/connectivity_service.dart';

class ConnectivityViewModel extends ChangeNotifier {
  final ConnectivityService _service;

  bool _hasInternet = true; // Default to true, will check immediately
  String _connectionType = 'unknown'; // 'wifi', 'mobile', 'ethernet', 'none'

  ConnectivityViewModel(this._service) {
    _init();
  }

  bool get hasInternet => _hasInternet;
  String get connectionType => _connectionType;

  Future<void> _init() async {
    // Initial check
    await checkConnectivity();

    // Listen to connectivity changes
    _service.onConnectivityChanged().listen((hasConnection) {
      _hasInternet = hasConnection;
      notifyListeners();
    });
  }

  Future<void> checkConnectivity() async {
    _hasInternet = await _service.hasInternet();
    _connectionType = await _service.getConnectionType();
    notifyListeners();
  }

  /// Get error message for no internet
  String getNoInternetMessage() {
    return 'لا توجد اتصالات إنترنت متاحة. يرجى التحقق من اتصالك بالإنترنت والمحاولة مجددًا.';
  }
}
