// ignore_for_file: unnecessary_non_null_assertion

import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/drive/v3.dart' as drive_api;
import 'package:http/http.dart' as http;
import 'package:madakhel_app/core/utils.dart';
import 'package:madakhel_app/data/auth/auth_service.dart';
import 'package:madakhel_app/data/auth/auth_storage.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/auth_user.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class BackupService {
  static const _backupBucket = 'madakhel-backup';
  static const _backupFolder = 'backups';
  static const _chunkSize = 2 * 1024 * 1024; // 2 MB
  static const _manifestVersion = 1;
  static const _gdriveFolderName = 'Madakhel Backups';
  final List<String> scopes = [drive.DriveApi.driveFileScope];
  final gSignIn = GoogleSignIn.instance;

  final AppDatabase _db;
  final AuthService _auth;
  final SupabaseClient _supabase;
  final http.Client _httpClient;

  BackupService(
    this._db,
    this._auth, {
    SupabaseClient? supabase,
    http.Client? httpClient,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _httpClient = httpClient ?? http.Client();

  /// Backup data to Google Drive using the authenticated user's access token.
  /// This is the primary backup method replacing Supabase.
  Future<String> backupToDrive() async {
    final gSignInClientAuthorization = await gSignIn.authorizationClient
        .authorizeScopes(scopes);
    final accessToken = gSignInClientAuthorization.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw StateError(
        'No Google access token available. Please sign in again.',
      );
    }

    final user = _requireSignedInUser();
    final backupOwner = _backupOwner(user);
    final backupTime = DateTime.now().toUtc();

    // Prepare backup data
    final incomeSources = await (_db.select(
      _db.incomeSources,
    )..where((incomeTable) => incomeTable.userId.equals(backupOwner))).get();
    final categories = await (_db.select(
      _db.transactionCategories,
    )..where((t) => t.userId.equals(backupOwner))).get();
    final transactions = await (_db.select(
      _db.financialTransactions,
    )..where((t) => t.userId.equals(backupOwner))).get();

    if (incomeSources.isEmpty && categories.isEmpty && transactions.isEmpty) {
      throw StateError(
        'Cannot create a backup because there is no data to save yet.',
      );
    }

    // Convert categories with proper enum serialization
    const directionConverter = TransactionDirectionConverter();
    final categoriesJson = categories.map((cat) {
      final json = cat.toJson();
      json['direction'] = directionConverter.toSql(cat.direction);
      return json;
    }).toList();

    final transactionsJson = transactions.map((t) {
      final json = t.toJson();
      json['direction'] = directionConverter.toSql(t.direction);
      return json;
    }).toList();

    final payload = jsonEncode({
      'version': 1,
      'userEmail': user.email,
      'backupOwner': backupOwner,
      'timestamp': backupTime.toIso8601String(),
      incomeSourcesKey: incomeSources.map((e) => e.toJson()).toList(),
      transactionCategoriesKey: categoriesJson,
      financialTransactionsKey: transactionsJson,
    });

    // debugPrint(
    //   ">> backupToDrive: incomeSources: ${incomeSources.length}, "
    //   "categories: ${categories.length}, transactions: ${transactions.length}",
    // );

    final fileName = '$backupOwner-${backupTime.millisecondsSinceEpoch}.json';
    final result = await _uploadToDrive(
      fileName,
      utf8.encode(payload),
      accessToken,
    );

    debugPrint('Backup uploaded to Google Drive: $result');
    return result;
  }

  /// [DEAD CODE] [DEPRECATED] - No longer used, replaced by backupToDrive()
  /// This method was used for Supabase storage. Kept for reference only.
  /// Supabase backup is no longer active; all backups now go to Google Drive.
  Future<String> backupUserData() async {
    final user = _requireSignedInUser();
    final backupOwner = _backupOwner(user);
    final backupTime = DateTime.now().toUtc();
    final backupPath = _backupPath(backupOwner, backupTime);

    final incomeSources = await (_db.select(
      _db.incomeSources,
    )..where((incomeTable) => incomeTable.userId.equals(backupOwner))).get();
    final categories = await (_db.select(
      _db.transactionCategories,
    )..where((t) => t.userId.equals(backupOwner))).get();
    final transactions = await (_db.select(
      _db.financialTransactions,
    )..where((t) => t.userId.equals(backupOwner))).get();

    if (incomeSources.isEmpty && categories.isEmpty && transactions.isEmpty) {
      throw StateError(
        'Cannot create a backup because there is no data to save yet.',
      );
    }

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
    // Ensure transactions serialize `direction` as a string ('in'/'out')
    final transactionsJson = transactions.map((t) {
      final json = t.toJson();
      json['direction'] = directionConverter.toSql(t.direction);
      return json;
    }).toList();

    final payload = jsonEncode({
      'version': 1,
      'userEmail': user.email,
      'backupOwner': backupOwner,
      'timestamp': backupTime.toIso8601String(),
      incomeSourcesKey: incomeSources.map((e) => e.toJson()).toList(),
      transactionCategoriesKey: categoriesJson,
      financialTransactionsKey: transactionsJson,
    });
    debugPrint(">> payload $payload");
    await _uploadJsonBackup(backupPath, utf8.encode(payload));

    return backupPath;
  }

  /// Upload backup JSON file to Google Drive using the access token.
  /// Returns the file ID of the uploaded file.
  Future<String> _uploadToDrive(
    String fileName,
    List<int> fileData,
    String accessToken,
  ) async {
    try {
      final driveApi = drive_api.DriveApi(
        _GdriveClient(_httpClient, accessToken),
      );

      // First, try to find or create the "Madakhel Backups" folder
      final folderId = await _getOrCreateBackupFolder(driveApi);

      // Create the file metadata
      final fileMetadata = drive_api.File()
        ..name = fileName
        ..parents = [folderId]
        ..mimeType = 'application/json';

      // Upload the file
      final media = drive_api.Media(Stream.value(fileData), fileData.length);
      final file = await driveApi.files.create(
        fileMetadata,
        uploadMedia: media,
      );

      debugPrint('File uploaded to Google Drive: ${file.id}');
      return file.id ?? fileName;
    } catch (e) {
      debugPrint('Error uploading to Google Drive: $e');
      rethrow;
    }
  }

  /// Find or create the "Madakhel Backups" folder in Google Drive.
  /// Returns the folder ID.
  Future<String> _getOrCreateBackupFolder(drive_api.DriveApi driveApi) async {
    try {
      // Search for existing "Madakhel Backups" folder
      final query =
          "name = '$_gdriveFolderName' and mimeType = 'application/vnd.google-apps.folder' "
          "and trashed = false";
      final fileList = await driveApi.files.list(
        q: query,
        spaces: 'drive',
        pageSize: 1,
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id!;
      }

      // Create the folder if it doesn't exist
      final folderMetadata = drive_api.File()
        ..name = _gdriveFolderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await driveApi.files.create(folderMetadata);
      debugPrint('Created backup folder: ${createdFolder.id}');
      return createdFolder.id ?? _gdriveFolderName;
    } catch (e) {
      debugPrint('Error managing backup folder: $e');
      rethrow;
    }
  }

  /// Fetch backup data from Google Drive (latest backup file).
  /// This is the new method replacing Supabase fetchBackupData().
  /// Downloads the most recent backup file from G Drive and parses it.
  Future<Map<String, List<dynamic>>> fetchBackupDataFromGDrive() async {
    final gSignInClientAuthorization = await gSignIn.authorizationClient
        .authorizeScopes(scopes);
    final accessToken = gSignInClientAuthorization.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError(
        'No Google access token available. Please sign in again.',
      );
    }

    final user = _requireSignedInUser();
    final backupOwner = _backupOwner(user);

    try {
      final bytes = await _downloadLatestBackupFromGDrive(
        backupOwner,
        accessToken,
      );
      final decoded = jsonDecode(utf8.decode(bytes));

      if (decoded is! Map<String, dynamic>) {
        throw StateError('Invalid backup format from G Drive.');
      }

      _validateBackupOwner(decoded, backupOwner);

      return {
        incomeSourcesKey: _parseIncomeSources(
          _extractList(decoded[incomeSourcesKey]),
          backupOwner,
        ),
        transactionCategoriesKey: _parseCategories(
          _extractList(decoded[transactionCategoriesKey]),
          backupOwner,
        ),
        financialTransactionsKey: _parseTransactions(
          _extractList(decoded[financialTransactionsKey]),
          backupOwner,
        ),
      };
    } catch (e) {
      debugPrint('Error fetching backup from G Drive: $e');
      rethrow;
    }
  }

  /// Download the latest backup file from Google Drive.
  /// Returns the file contents as bytes.
  Future<Uint8List> _downloadLatestBackupFromGDrive(
    String backupOwner,
    String accessToken,
  ) async {
    try {
      final driveApi = drive_api.DriveApi(
        _GdriveClient(_httpClient, accessToken),
      );

      // Search for backup files in the Madakhel Backups folder
      final folderId = await _getOrCreateBackupFolder(driveApi);

      // List files in the backup folder, sorted by creation date (newest first)
      final query =
          "parents = '$folderId' and trashed = false and mimeType = 'application/json'";
      final fileList = await driveApi.files.list(
        q: query,
        spaces: 'drive',
        pageSize: 100,
        orderBy: 'createdTime desc',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        throw StateError('No backup files found on Google Drive.');
      }

      // Get the latest file (first in list due to orderBy desc)
      final latestFile = fileList.files!.first;
      final fileId = latestFile.id;

      if (fileId == null) {
        throw StateError('Unable to retrieve backup file ID from G Drive.');
      }

      debugPrint(
        'Downloading latest backup file: ${latestFile.name} (ID: $fileId)',
      );

      // Download the file
      final media =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive_api.DownloadOptions.fullMedia,
              )
              as drive_api.Media;

      final bytes = await _bytesFromMedia(media);
      debugPrint('Downloaded ${bytes.length} bytes from G Drive');
      return bytes;
    } catch (e) {
      debugPrint('Error downloading backup from G Drive: $e');
      rethrow;
    }
  }

  /// Convert Drive API Media stream to bytes.
  Future<Uint8List> _bytesFromMedia(drive_api.Media media) async {
    final builder = BytesBuilder(copy: false);
    try {
      await for (final chunk in media.stream.timeout(
        const Duration(milliseconds: 450),
      )) {
        builder.add(chunk);
      }
    } catch (e, st) {
      // Log/rethrow so callers know the download was incomplete
      rethrow;
    }
    return builder.toBytes();
  }

  // ========== DEAD CODE: Supabase backup implementation (kept for reference) ==========
  // The following methods use Supabase storage and are no longer in use.
  // Backup is now handled through Google Drive via backupToDrive().
  // These methods are preserved as dead code for potential future rollback.

  /// [DEPRECATED] Upload backup to Supabase storage.
  /// Use backupToDrive() instead.

  //   try {
  //     return await _latestBackupPath(_backupOwner(_requireSignedInUser())) !=
  //         null;
  //   } catch (_) {
  //     return false;
  //   }
  // }

  /// [DEAD CODE] [DEPRECATED] - No longer used, replaced by restoreUserDataFromGDrive()
  /// Kept for reference only. Uses Supabase storage which is not active.
  Future<void> restoreUserData() async {
    final user = _requireSignedInUser();
    final backupOwner = _backupOwner(user);
    final bytes = await _downloadLatestBackup(backupOwner);

    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid backup format.');
    }

    _validateBackupOwner(decoded, backupOwner);
    final incomeSources = _parseIncomeSources(
      _extractList(decoded[incomeSourcesKey]),
      backupOwner,
    );
    final categories = _parseCategories(
      _extractList(decoded[transactionCategoriesKey]),
      backupOwner,
    );
    final transactions = _parseTransactions(
      _extractList(decoded[financialTransactionsKey]),
      backupOwner,
    );

    if (incomeSources.isEmpty && categories.isEmpty && transactions.isEmpty) {
      throw StateError(
        'Cannot restore backup because the backup file is empty.',
      );
    }

    await _db.transaction(() async {
      await (_db.delete(
        _db.financialTransactions,
      )..where((t) => t.userId.equals(backupOwner))).go();
      await (_db.delete(
        _db.transactionCategories,
      )..where((t) => t.userId.equals(backupOwner))).go();
      await (_db.delete(
        _db.incomeSources,
      )..where((t) => t.userId.equals(backupOwner))).go();

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
        // Backup format is assumed to include denormalized `direction`.
        final dir = transaction.direction;

        await _db
            .into(_db.financialTransactions)
            .insert(
              FinancialTransactionsCompanion(
                id: Value(transaction.id),
                userId: Value(transaction.userId),
                incomeSourceId: Value(transaction.incomeSourceId),
                categoryId: Value(transaction.categoryId),
                isSystem: Value(transaction.isSystem),
                direction: Value(dir),
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

  /// Restore user data from Google Drive (full replacement).
  /// Downloads the latest backup from G Drive and replaces all local data with it.
  /// This is the G Drive version of restoreUserData().
  Future<void> restoreUserDataFromGDrive() async {
    final authStorageInstance = await AuthUserStorage.instance();
    final accessToken = await authStorageInstance.storedAccessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw StateError(
        'No Google access token available. Please sign in again.',
      );
    }

    final user = _requireSignedInUser();
    final backupOwner = _backupOwner(user);

    try {
      // Fetch the latest backup from G Drive
      final bytes = await _downloadLatestBackupFromGDrive(
        backupOwner,
        accessToken,
      );
      final decoded = jsonDecode(utf8.decode(bytes));

      if (decoded is! Map<String, dynamic>) {
        throw StateError('Invalid backup format from G Drive.');
      }

      _validateBackupOwner(decoded, backupOwner);

      // Parse the backup data
      final incomeSources = _parseIncomeSources(
        _extractList(decoded[incomeSourcesKey]),
        backupOwner,
      );
      final categories = _parseCategories(
        _extractList(decoded[transactionCategoriesKey]),
        backupOwner,
      );
      final transactions = _parseTransactions(
        _extractList(decoded[financialTransactionsKey]),
        backupOwner,
      );

      if (incomeSources.isEmpty && categories.isEmpty && transactions.isEmpty) {
        throw StateError(
          'Cannot restore backup because the backup file is empty.',
        );
      }

      // Perform the database transaction
      await _db.transaction(() async {
        await (_db.delete(
          _db.financialTransactions,
        )..where((t) => t.userId.equals(backupOwner))).go();
        await (_db.delete(
          _db.transactionCategories,
        )..where((t) => t.userId.equals(backupOwner))).go();
        await (_db.delete(
          _db.incomeSources,
        )..where((t) => t.userId.equals(backupOwner))).go();

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
          final dir = transaction.direction;
          await _db
              .into(_db.financialTransactions)
              .insert(
                FinancialTransactionsCompanion(
                  id: Value(transaction.id),
                  userId: Value(transaction.userId),
                  incomeSourceId: Value(transaction.incomeSourceId),
                  categoryId: Value(transaction.categoryId),
                  isSystem: Value(transaction.isSystem),
                  direction: Value(dir),
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

      debugPrint('Restoration from G Drive completed successfully.');
    } catch (e) {
      debugPrint('Error restoring from G Drive: $e');
      rethrow;
    }
  }

  /// [DEAD CODE] [DEPRECATED] - No longer used, replaced by fetchBackupDataFromGDrive()
  /// Kept for reference only. Uses Supabase storage which is not active.
  /// Fetches the parsed backup data without applying it to the local DB.
  /// Useful for merge/preview operations.
  Future<Map<String, List<dynamic>>> fetchBackupData() async {
    final user = _requireSignedInUser();
    final backupOwner = _backupOwner(user);
    final bytes = await _downloadLatestBackup(backupOwner);
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid backup format.');
    }

    _validateBackupOwner(decoded, backupOwner);

    return {
      incomeSourcesKey: _parseIncomeSources(
        _extractList(decoded[incomeSourcesKey]),
        backupOwner,
      ),
      transactionCategoriesKey: _parseCategories(
        _extractList(decoded[transactionCategoriesKey]),
        backupOwner,
      ),
      financialTransactionsKey: _parseTransactions(
        _extractList(decoded[financialTransactionsKey]),
        backupOwner,
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
      // Expect the JSON to contain a string direction value ("in"/"out").
      json['direction'] = const TransactionDirectionConverter().fromSql(
        json['direction'] as String,
      );
      return FinancialTransaction.fromJson(json);
    }).toList();
  }

  /// [DEAD CODE] [DEPRECATED] - No longer used, replaced by _uploadToDrive()
  /// Kept for reference only. Uses Supabase storage which is not active.
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

  /// [DEAD CODE] [DEPRECATED] - No longer used, replaced by Google Drive backup
  /// Kept for reference only. Uses Supabase storage which is not active.
  Future<Uint8List> _downloadLatestBackup(String uid) async {
    final path = await _latestBackupPath(uid);
    // debugPrint('Latest backup path for $path');
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
      return await _downloadChunkedBackup(decoded);
    }

    return bytes;
  }

  /// [DEAD CODE] [DEPRECATED] - Helper for Supabase chunked downloads
  /// Kept for reference only.
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

  /// [DEAD CODE] [DEPRECATED] - Helper for finding latest Supabase backup
  /// Kept for reference only.
  Future<String?> _latestBackupPath(String uid) async {
    try {
      final filesObjects = await _supabase.storage
          .from(_backupBucket)
          .list(path: '$_backupFolder/$uid');

      if (filesObjects.isEmpty) {
        debugPrint('No backup files found for user: $uid');
        return null;
      }

      String? latestFileName;
      for (final fileObject in filesObjects) {
        final name = fileObject.name;
        if (!name.endsWith('.json')) {
          continue;
        }

        final stem = name.substring(0, name.length - 5);
        if (int.tryParse(stem) == null) {
          continue;
        }

        if (latestFileName == null) {
          latestFileName = name;
          continue;
        }

        final currentStem = latestFileName!.substring(
          0,
          latestFileName!.length - 5,
        );
        if (int.parse(stem) > int.parse(currentStem)) {
          latestFileName = name;
        }
      }

      if (latestFileName == null) {
        return null;
      }

      return '$_backupFolder/$uid/$latestFileName';
    } catch (e) {
      debugPrint('No backup folder found for user $uid: $e');
      return null;
    }
  }

  String _backupPath(String uid, DateTime timestamp) {
    final fileName = timestamp.millisecondsSinceEpoch.toString();
    return '$_backupFolder/$uid/$fileName.json';
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

  String newestDateEpoch(int a, int b) =>
      DateTime.fromMillisecondsSinceEpoch(
        a,
        isUtc: true,
      ).isAfter(DateTime.fromMillisecondsSinceEpoch(b, isUtc: true))
      ? a.toString()
      : b.toString();
}

/// Helper class to add authorization headers to HTTP requests for Google Drive API.
/// This enables the googleapis package to make authenticated requests.
class _GdriveClient extends http.BaseClient {
  final http.Client _inner;
  final String _accessToken;

  _GdriveClient(this._inner, this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }
}
