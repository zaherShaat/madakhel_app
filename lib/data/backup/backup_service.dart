import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';
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
    final uid = user.uid;
    final backupTime = DateTime.now().toUtc();
    final backupPath = _backupPath(uid, backupTime);

    final incomeSources = await (_db.select(
      _db.incomeSources,
    )..where((incomeTable) => incomeTable.userId.equals(uid))).get();
    final categories = await (_db.select(
      _db.transactionCategories,
    )..where((t) => t.userId.equals(uid))).get();
    final transactions = await (_db.select(
      _db.financialTransactions,
    )..where((t) => t.userId.equals(uid))).get();
    //  final directories=await (_db.select(
    //     _db.,
    //   )..where((t) => t.userId.equals(uid))).get();
    // Convert categories with proper enum serialization
    const directionConverter = TransactionDirectionConverter();
    final categoriesJson = categories.map((cat) {
      final json = cat.toJson();
      // Ensure direction is serialized as string ('in' or 'out')
      json['direction'] = directionConverter.toSql(cat.direction);
      return json;
    }).toList();

    final payload = jsonEncode({
      'version': 1,
      'userId': uid,
      'timestamp': backupTime.toIso8601String(),
      'incomeSources': incomeSources.map((e) => e.toJson()).toList(),
      'transactionCategories': categoriesJson,
      'financialTransactions': transactions.map((e) => e.toJson()).toList(),
    });

    await _uploadJsonBackup(backupPath, utf8.encode(payload));

    return backupPath;
  }

  Future<bool> backupExists() async {
    try {
      return await _latestBackupPath(_requireSignedInUser().uid) != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> restoreUserData() async {
    final uid = _requireSignedInUser().uid;
    final bytes = await _downloadLatestBackup(uid);

    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid backup format.');
    }

    final backupUserId = decoded['userId'];
    if (backupUserId != uid) {
      throw StateError('Backup belongs to a different user.');
    }

    final incomeSourcesJson = _extractList(decoded['incomeSources']);
    final categoriesJson = _extractList(decoded['transactionCategories']);
    final transactionsJson = _extractList(decoded['financialTransactions']);

    final incomeSources = incomeSourcesJson
        .map((item) => IncomeSource.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    // Handle TransactionDirection enum deserialization
    const directionConverter = TransactionDirectionConverter();
    final categories = categoriesJson.map((item) {
      final catJson = Map<String, dynamic>.from(item);
      // Convert direction string back to enum if needed
      if (catJson['direction'] is String) {
        catJson['direction'] = directionConverter.fromSql(
          catJson['direction'] as String,
        );
      }
      return TransactionCategory.fromJson(catJson);
    }).toList();

    final transactions = transactionsJson
        .map(
          (item) =>
              FinancialTransaction.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

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
    final uid = _requireSignedInUser().uid;
    final bytes = await _downloadLatestBackup(uid);

    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid backup format.');
    }

    final incomeSourcesJson = _extractList(decoded['incomeSources']);
    final categoriesJson = _extractList(decoded['transactionCategories']);
    final transactionsJson = _extractList(decoded['financialTransactions']);

    final incomeSources = incomeSourcesJson
        .map((item) => IncomeSource.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    // Handle TransactionDirection enum deserialization
    const directionConverter = TransactionDirectionConverter();
    final categories = categoriesJson.map((item) {
      final catJson = Map<String, dynamic>.from(item);
      // Convert direction string back to enum if needed
      if (catJson['direction'] is String) {
        catJson['direction'] = directionConverter.fromSql(
          catJson['direction'] as String,
        );
      }
      return TransactionCategory.fromJson(catJson);
    }).toList();

    final transactions = transactionsJson
        .map(
          (item) =>
              FinancialTransaction.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    return {
      'incomeSources': incomeSources,
      'transactionCategories': categories,
      'financialTransactions': transactions,
    };
  }

  AuthUser _requireSignedInUser() {
    final user = _auth.currentAuthUser;
    if (user == null) {
      throw StateError('No signed-in user available for backup.');
    }
    return user;
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

  Future<Uint8List> _downloadLatestBackup(String uid) async {
    final path = await _latestBackupPath(uid);
    if (path == null) {
      throw StateError('No backup is available to restore.');
    }

    final storage = _supabase.storage.from(_backupBucket);
    final bytes = await storage.download(path);
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

  Future<String?> _latestBackupPath(String uid) async {
    final files = await _supabase.storage
        .from(_backupBucket)
        .list(
          path: '$_backupFolder/$uid',
          searchOptions: const SearchOptions(
            limit: 100,
            sortBy: SortBy(column: 'name', order: 'desc'),
            search: '.json',
          ),
        );

    String? latestFileName;
    DateTime? latestTimestamp;

    for (final file in files) {
      final timestamp = _timestampFromBackupFileName(file.name);
      if (timestamp == null) continue;

      if (latestTimestamp == null || timestamp.isAfter(latestTimestamp)) {
        latestTimestamp = timestamp;
        latestFileName = file.name;
      }
    }

    if (latestFileName == null) return null;

    return '$_backupFolder/$uid/$latestFileName';
  }

  String _backupPath(String uid, DateTime timestamp) {
    final fileName = timestamp
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('.', '')
        .replaceAll('-', '');
    return '$_backupFolder/$uid/$fileName.json';
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
