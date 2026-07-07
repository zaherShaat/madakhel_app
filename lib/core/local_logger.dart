import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A very small, dependency-light local logger that appends timestamped
/// events to a single rotating file under the app documents directory.
class LocalLogger {
  LocalLogger._internal();

  static final LocalLogger instance = LocalLogger._internal();

  File? _logFile;
  IOSink? _sink;
  Future<void>? _initFuture;

  Future<void> _ensureInitialized() {
    if (_initFuture != null) return _initFuture!;

    _initFuture = () async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final logsDir = Directory(p.join(dir.path, 'logs'));
        if (!await logsDir.exists()) await logsDir.create(recursive: true);
        _logFile = File(p.join(logsDir.path, 'local_operations.log'));
        if (!await _logFile!.exists()) await _logFile!.create(recursive: true);
        _sink = _logFile!.openWrite(
          mode: FileMode.append,
          encoding: Utf8Codec(),
        );
      } catch (e) {
        // If initialization fails we don't crash the app — just print.
        debugPrint('LocalLogger init error: $e');
      }
    }();

    return _initFuture!;
  }

  Future<void> log(String tag, String message) async {
    try {
      await _ensureInitialized();
      final ts = DateTime.now().toIso8601String();
      final line = '[$ts] [$tag] $message\n';
      if (_sink != null) {
        _sink!.write(line);
        await _sink!.flush();
      } else {
        debugPrint(line);
      }
    } catch (e) {
      debugPrint('LocalLogger write error: $e');
    }
  }

  /// Convenience helpers
  Future<void> logDb(String action, String details) =>
      log('DB', '$action: $details');
  Future<void> logBackup(String action, String details) =>
      log('BACKUP', '$action: $details');

  /// Close sink (useful for tests or graceful shutdown)
  Future<void> close() async {
    try {
      await _sink?.flush();
      await _sink?.close();
      _sink = null;
      _logFile = null;
      _initFuture = null;
    } catch (_) {}
  }
}
