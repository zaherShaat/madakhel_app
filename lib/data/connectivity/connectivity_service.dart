import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  /// First checks for WiFi, then checks for mobile/other internet
  Future<bool> hasInternet() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // Check if connected to WiFi or mobile network
      final hasConnection =
          connectivityResult ==ConnectivityResult.wifi ||
          connectivityResult ==ConnectivityResult.mobile ||
          connectivityResult ==ConnectivityResult.ethernet;

      return hasConnection;
    } catch (e) {
      // If we can't determine, assume no internet
      return false;
    }
  }

  /// Get the type of internet connection
  /// Returns 'wifi', 'mobile', 'ethernet', or 'none'
  Future<String> getConnectionType() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult == ConnectivityResult.wifi) {
        return 'wifi';
      } else if (connectivityResult == ConnectivityResult.mobile) {
        return 'mobile';
      } else if (connectivityResult == ConnectivityResult.ethernet) {
        return 'ethernet';
      } else {
        return 'none';
      }
    } catch (e) {
      return 'none';
    }
  }

  /// Stream to listen to connectivity changes
  Stream<bool> onConnectivityChanged() {
    return _connectivity.onConnectivityChanged.map((result) {
      return result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet;
    });
  }
}
