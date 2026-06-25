import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:madakhel_app/data/auth/auth_service.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/auth_user.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class BackupService {
  static const _backupBucket = 'madakhel-backup';
  static const _backupFolder = 'backups';
  static const _chunkSize = 2 * 1024 * 1024; // 2 MB
  static const _manifestVersion = 1;

  final AppDatabase _db;
  final AuthService _auth;
  final SupabaseClient _supabase;

  BackupService(this._db, this._auth, {SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<String> backupUserData() async {
    final user = _requireSignedInUser();
    final uid = user.email!;
    final backupOwner = _backupOwner(user);
    final backupTime = DateTime.now().toUtc();
    final backupPath = _backupPath(backupOwner, backupTime);

    final incomeSources = await (_db.select(
      _db.incomeSources,
    )..where((incomeTable) => incomeTable.userId.equals(uid))).get();
    final categories = await (_db.select(
      _db.transactionCategories,
    )..where((t) => t.userId.equals(uid))).get();
    final transactions = await (_db.select(
      _db.financialTransactions,
    )..where((t) => t.userId.equals(uid))).get();

    // Convert categories with proper enum serialization
    const directionConverter = TransactionDirectionConverter();
    final categoriesJson = categories.map((cat) {
      final json = cat.toJson();
      // Ensure direction is serialized as string ('in' or 'out')
      json['direction'] = directionConverter.toSql(cat.direction);
      return json;
    }).toList();
    debugPrint(
      ">> backupUserData: incomeSources: ${incomeSources.length}, categories: ${categories.length}, transactions: ${transactions.length}",
    );
    final payload = jsonEncode({
      'version': 1,
      'userEmail': user.email,
      'backupOwner': backupOwner,
      'timestamp': backupTime.toIso8601String(),
      'incomeSources': incomeSources.map((e) => e.toJson()).toList(),
      'transactionCategories': categoriesJson,
      'financialTransactions': transactions.map((e) => e.toJson()).toList(),
    });
    debugPrint(">> payload $payload");
    await _uploadJsonBackup(backupPath, utf8.encode(payload));

    return backupPath;
  }

  // Future<bool> backupExists() async {
  //   try {
  //     return await _latestBackupPath(_backupOwner(_requireSignedInUser())) !=
  //         null;
  //   } catch (_) {
  //     return false;
  //   }
  // }

  Future<void> restoreUserData() async {
    final user = _requireSignedInUser();
    final uid = user.email!;
    final backupOwner = _backupOwner(user);
    final bytes = await _downloadLatestBackup(backupOwner);

    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid backup format.');
    }

    _validateBackupOwner(decoded, backupOwner);
    final incomeSources = _parseIncomeSources(
      _extractList(decoded['incomeSources']),
      uid,
    );
    final categories = _parseCategories(
      _extractList(decoded['transactionCategories']),
      uid,
    );
    final transactions = _parseTransactions(
      _extractList(decoded['financialTransactions']),
      uid,
    );

    await _db.transaction(() async {
      await (_db.delete(
        _db.financialTransactions,
      )..where((t) => t.userId.equals(uid))).go();
      await (_db.delete(
        _db.transactionCategories,
      )..where((t) => t.userId.equals(uid))).go();
      await (_db.delete(
        _db.incomeSources,
      )..where((t) => t.userId.equals(uid))).go();

      for (final source in incomeSources) {
        await _db
            .into(_db.incomeSources)
            .insert(
              IncomeSourcesCompanion(
                id: Value(source.id),
                userId: Value(source.userId),
                name: Value(source.name),
                currency: Value(source.currency),
                starterBalance: Value(source.starterBalance),
                createdAt: Value(source.createdAt),
                updatedAt: Value(source.updatedAt),
                syncStatus: Value(source.syncStatus),
                remoteId: Value(source.remoteId),
                isDeleted: Value(source.isDeleted),
              ),
            );
      }

      for (final category in categories) {
        await _db
            .into(_db.transactionCategories)
            .insert(
              TransactionCategoriesCompanion(
                id: Value(category.id),
                userId: Value(category.userId),
                name: Value(category.name),
                direction: Value(category.direction),
                createdAt: Value(category.createdAt),
                updatedAt: Value(category.updatedAt),
                syncStatus: Value(category.syncStatus),
                remoteId: Value(category.remoteId),
                isDeleted: Value(category.isDeleted),
              ),
            );
      }

      for (final transaction in transactions) {
        await _db
            .into(_db.financialTransactions)
            .insert(
              FinancialTransactionsCompanion(
                id: Value(transaction.id),
                userId: Value(transaction.userId),
                incomeSourceId: Value(transaction.incomeSourceId),
                categoryId: Value(transaction.categoryId),
                isSystem: Value(transaction.isSystem),
                amount: Value(transaction.amount),
                note: Value(transaction.note),
                date: Value(transaction.date),
                createdAt: Value(transaction.createdAt),
                updatedAt: Value(transaction.updatedAt),
                syncStatus: Value(transaction.syncStatus),
                remoteId: Value(transaction.remoteId),
                isDeleted: Value(transaction.isDeleted),
              ),
            );
      }
    });
  }

  /// Fetches the parsed backup data without applying it to the local DB.
  /// Useful for merge/preview operations.
  Future<Map<String, List<dynamic>>> fetchBackupData() async {
    final user = _requireSignedInUser();
    final uid = user.uid;
    final backupOwner = _backupOwner(user);
    final bytes = await _downloadLatestBackup(backupOwner);

    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid backup format.');
    }

    _validateBackupOwner(decoded, backupOwner);

    return {
      'incomeSources': _parseIncomeSources(
        _extractList(decoded['incomeSources']),
        uid,
      ),
      'transactionCategories': _parseCategories(
        _extractList(decoded['transactionCategories']),
        uid,
      ),
      'financialTransactions': _parseTransactions(
        _extractList(decoded['financialTransactions']),
        uid,
      ),
    };
  }

  AuthUser _requireSignedInUser() {
    final user = _auth.currentAuthUser;
    if (user == null) {
      throw StateError('No signed-in user available for backup.');
    }
    return user;
  }

  String _backupOwner(AuthUser user) {
    final email = user.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      throw StateError('No signed-in user email available for backup.');
    }
    debugPrint('Backup owner: $email');
    return email;
  }

  void _validateBackupOwner(Map<String, dynamic> decoded, String backupOwner) {
    final rawOwner = decoded['backupOwner'] ?? decoded['userEmail'];
    if (rawOwner is! String || rawOwner.trim().toLowerCase() != backupOwner) {
      throw StateError('Backup belongs to a different user.');
    }
  }

  List<IncomeSource> _parseIncomeSources(
    List<Map<String, dynamic>> items,
    String uid,
  ) {
    return items.map((item) {
      final json = Map<String, dynamic>.from(item);
      json['userId'] = uid;
      return IncomeSource.fromJson(json);
    }).toList();
  }

  List<TransactionCategory> _parseCategories(
    List<Map<String, dynamic>> items,
    String uid,
  ) {
    const directionConverter = TransactionDirectionConverter();
    return items.map((item) {
      final json = Map<String, dynamic>.from(item);
      json['userId'] = uid;
      if (json['direction'] is String) {
        json['direction'] = directionConverter.fromSql(
          json['direction'] as String,
        );
      }
      return TransactionCategory.fromJson(json);
    }).toList();
  }

  List<FinancialTransaction> _parseTransactions(
    List<Map<String, dynamic>> items,
    String uid,
  ) {
    return items.map((item) {
      final json = Map<String, dynamic>.from(item);
      json['userId'] = uid;
      return FinancialTransaction.fromJson(json);
    }).toList();
  }

  Future<void> _uploadJsonBackup(String path, List<int> payload) async {
    final bytes = Uint8List.fromList(payload);
    final storage = _supabase.storage.from(_backupBucket);

    if (bytes.length <= _chunkSize) {
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'application/json',
          upsert: true,
        ),
      );
      return;
    }

    final chunks = <String>[];
    for (var offset = 0; offset < bytes.length; offset += _chunkSize) {
      final chunkIndex = chunks.length;
      final end = offset + _chunkSize > bytes.length
          ? bytes.length
          : offset + _chunkSize;
      final chunkPath = '$path.part${chunkIndex.toString().padLeft(3, '0')}';
      await storage.uploadBinary(
        chunkPath,
        Uint8List.sublistView(bytes, offset, end),
        fileOptions: const FileOptions(
          contentType: 'application/octet-stream',
          upsert: true,
        ),
      );
      chunks.add(chunkPath);
    }

    final manifest = jsonEncode({
      'manifestVersion': _manifestVersion,
      'chunked': true,
      'contentType': 'application/json',
      'size': bytes.length,
      'chunks': chunks,
    });

    await storage.uploadBinary(
      path,
      Uint8List.fromList(utf8.encode(manifest)),
      fileOptions: const FileOptions(
        contentType: 'application/json',
        upsert: true,
      ),
    );
  }

  Future<Uint8List> _downloadLatestBackup(String backupOwner) async {
    final path = await _latestBackupPath(backupOwner);
    debugPrint('Latest backup path for $path');
    if (path == null) {
      throw StateError('No backup is available to restore.');
    }

    final storage = _supabase.storage.from(_backupBucket);
    final bytes = await storage.download(path);
    debugPrint("${bytes.length} bytes downloaded from $path");
    if (bytes.isEmpty) {
      throw StateError('No backup is available to restore.');
    }

    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is Map<String, dynamic> && decoded['chunked'] == true) {
      return _downloadChunkedBackup(decoded);
    }

    return bytes;
  }

  Future<Uint8List> _downloadChunkedBackup(
    Map<String, dynamic> manifest,
  ) async {
    final chunks = manifest['chunks'];
    if (chunks is! List || chunks.isEmpty) {
      throw StateError('Invalid backup format.');
    }

    final storage = _supabase.storage.from(_backupBucket);
    final builder = BytesBuilder(copy: false);
    for (final chunk in chunks) {
      if (chunk is! String) {
        throw StateError('Invalid backup format.');
      }
      builder.add(await storage.download(chunk));
    }

    final bytes = builder.takeBytes();
    if (manifest['size'] is int && bytes.length != manifest['size']) {
      throw StateError('Invalid backup format.');
    }
    return bytes;
  }

  Future<String?> _latestBackupPath(String backupOwner) async {
    debugPrint(
      'Fetching latest backup path for $backupOwner >>$_backupBucket / $_backupFolder/$backupOwner',
    );
    final files = await _supabase.storage
        .from(_backupBucket)
        .list(
          path: '$_backupFolder/$backupOwner',
          // searchOptions: const SearchOptions(limit: 100, search: '.json'),
        );
    debugPrint("${files.length} >> files");
    String? latestFileName;
    DateTime? latestTimestamp;

    for (final file in files) {
      if (!_isBackupFileName(file.name)) continue;

      final timestamp =
          _timestampFromBackupFileName(file.name) ??
          _timestampFromStorageFile(file);
      if (timestamp == null) continue;

      if (latestTimestamp == null || timestamp.isAfter(latestTimestamp)) {
        latestTimestamp = timestamp;
        latestFileName = file.name;
      }
    }

    if (latestFileName == null) return null;

    return '$_backupFolder/$backupOwner/$latestFileName';
  }

  bool _isBackupFileName(String fileName) {
    return fileName.endsWith('.json') && !fileName.contains('.part');
  }

  DateTime? _timestampFromStorageFile(FileObject file) {
    return _parseStorageTimestamp(file.createdAt) ??
        _parseStorageTimestamp(file.updatedAt);
  }

  DateTime? _parseStorageTimestamp(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  String _backupPath(String backupOwner, DateTime timestamp) {
    final fileName = timestamp
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('.', '')
        .replaceAll('-', '');
    return '$_backupFolder/$backupOwner/$fileName.json';
  }

  DateTime? _timestampFromBackupFileName(String fileName) {
    final match = RegExp(
      r'^(\d{8})T(\d{6})(\d{3,6})Z\.json$',
    ).firstMatch(fileName);
    if (match == null) return null;

    final date = match.group(1)!;
    final time = match.group(2)!;
    final fraction = match.group(3)!.padRight(6, '0');

    return DateTime.tryParse(
      '${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}'
      'T${time.substring(0, 2)}:${time.substring(2, 4)}:${time.substring(4, 6)}'
      '.$fraction'
      'Z',
    );
  }

  List<Map<String, dynamic>> _extractList(Object? raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .cast<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    throw StateError('Expected a JSON array but got ${raw.runtimeType}.');
  }
}
