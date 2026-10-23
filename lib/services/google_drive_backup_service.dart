import 'dart:typed_data';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';

import '../config/google_oauth_config.dart';
import '../core/app_info.dart';
import '../core/incoming_share.dart';

/// Uploads / downloads encrypted Amanaat `.amanahbak` files on Google Drive.
class GoogleDriveBackupService {
  static final GoogleSignIn _signIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
      drive.DriveApi.driveReadonlyScope,
    ],
    serverClientId: GoogleOAuthConfig.webClientId,
  );

  static Future<GoogleSignInAccount?> currentUser() =>
      _signIn.signInSilently();

  static String get setupHelpMessage =>
      'Google Drive setup required (developer error 10).\n\n'
      'Package:\n${GoogleOAuthConfig.androidPackage}\n\n'
      'THIS APK SHA-1 (must exist as Android OAuth client):\n'
      '${GoogleOAuthConfig.apkSha1}\n\n'
      'Web client (same project):\n${GoogleOAuthConfig.webClientId}\n\n'
      '1. Cloud project model-charge-510905-q4\n'
      '2. Clients → Create Android client "Amanaat this PC"\n'
      '   Package = ${GoogleOAuthConfig.androidPackage}\n'
      '   SHA-1 = ${GoogleOAuthConfig.apkSha1}\n'
      '3. Audience → Test user = your Gmail\n'
      '4. Drive API enabled\n'
      '5. Uninstall app → install latest APK → try again';

  static bool _isDeveloperError(Object e) {
    final s = e.toString();
    if (s.contains('DEVELOPER_ERROR')) return true;
    if (RegExp(r'ApiException:\s*10\b').hasMatch(s)) return true;
    if (RegExp(r'sign_in_failed.*\b10\b').hasMatch(s)) return true;
    return false;
  }

  static bool _isNetworkUploadError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('broken pipe') ||
        s.contains('connection reset') ||
        s.contains('connection closed') ||
        s.contains('socketexception') ||
        s.contains('clientexception') ||
        s.contains('timed out') ||
        s.contains('timeout');
  }

  /// Clears the cached Google session so the next [signIn] can show every
  /// account on the phone (not only the last one, e.g. after Destroy vault).
  static Future<void> _clearCachedAccount() async {
    try {
      await _signIn.signOut();
    } catch (_) {}
    try {
      await _signIn.disconnect();
    } catch (_) {}
  }

  /// [forceAccountPicker] = true for "Connect Google Drive" so the user can
  /// choose any Gmail on the device. Upload/restore keep silent sign-in.
  static Future<GoogleSignInAccount?> signIn({
    bool forceAccountPicker = false,
  }) async {
    try {
      if (forceAccountPicker) {
        await _clearCachedAccount();
        return await _signIn.signIn();
      }
      return await _signIn.signInSilently() ?? await _signIn.signIn();
    } on PlatformException catch (e) {
      if (_isDeveloperError(e)) throw setupHelpMessage;
      throw 'Google sign-in failed: ${e.message ?? e.code}';
    } catch (e) {
      if (_isDeveloperError(e)) throw setupHelpMessage;
      throw 'Google sign-in failed: $e';
    }
  }

  static Future<void> signOut() => _clearCachedAccount();

  static Future<drive.DriveApi> _api() async {
    final account = await signIn();
    if (account == null) throw 'Sign-in cancelled';
    final client = await _signIn.authenticatedClient();
    if (client == null) throw 'Could not authorize Google Drive';
    return drive.DriveApi(client);
  }

  static String timestampedFileName() {
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'Amanaat_$stamp.amanahbak';
  }

  static Stream<List<int>> _chunked(Uint8List bytes, int chunkSize) async* {
    for (var i = 0; i < bytes.length; i += chunkSize) {
      final end =
          i + chunkSize > bytes.length ? bytes.length : i + chunkSize;
      yield bytes.sublist(i, end);
    }
  }

  static Future<drive.File?> _findLatestBackup(drive.DriveApi api) async {
    final list = await api.files.list(
      q: "(name contains 'Amanaat_' or name contains 'amanaat-backup') and "
          "(name contains '.amanahbak') and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name, modifiedTime, size)',
      orderBy: 'modifiedTime desc',
      pageSize: 20,
    );
    final files = list.files;
    if (files == null || files.isEmpty) return null;
    return files.first;
  }

  /// Upload encrypted vault bytes to Drive.
  static Future<DateTime?> uploadBackup(
    Uint8List bytes, {
    void Function(String status)? onStatus,
  }) async {
    if (!looksLikeAmanaatBackup(bytes)) {
      throw 'Not a valid $kAppName backup file.';
    }
    final mb = (bytes.length / (1024 * 1024)).toStringAsFixed(2);
    final fileName = timestampedFileName();
    const chunkSize = 2 * 1024 * 1024;

    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        onStatus?.call(
          attempt == 1
              ? 'Uploading $mb MB…'
              : 'Retry $attempt · uploading $mb MB…',
        );
        final api = await _api();
        final media = drive.Media(
          _chunked(bytes, chunkSize),
          bytes.length,
          contentType: 'application/octet-stream',
        );
        final result = await api.files
            .create(
              drive.File()
                ..name = fileName
                ..mimeType = 'application/octet-stream',
              uploadMedia: media,
              uploadOptions: drive.ResumableUploadOptions(
                numberOfAttempts: 5,
                chunkSize: chunkSize,
              ),
            )
            .timeout(
              const Duration(minutes: 8),
              onTimeout: () =>
                  throw 'Upload timed out after 8 minutes ($mb MB). Use Wi‑Fi.',
            );
        onStatus?.call('Upload complete');
        return result.modifiedTime;
      } catch (e) {
        lastError = e;
        if (_isDeveloperError(e)) throw setupHelpMessage;
        if (!_isNetworkUploadError(e) || attempt == 3) {
          throw e.toString();
        }
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }
    throw lastError?.toString() ?? 'Upload failed';
  }

  /// Download the latest Amanaat backup from Drive.
  static Future<Uint8List> downloadBackup({
    void Function(String status)? onStatus,
  }) async {
    onStatus?.call('Finding backup on Drive…');
    final api = await _api();
    final file = await _findLatestBackup(api);
    final fileId = file?.id;
    if (fileId == null) {
      throw 'No $kAppName backup found on Google Drive. Sync a backup first.';
    }
    final fileName = file?.name ?? 'backup';

    onStatus?.call('Downloading $fileName…');
    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final builder = BytesBuilder(copy: false);
    await for (final chunk in media.stream) {
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    if (!looksLikeAmanaatBackup(bytes)) {
      throw 'Downloaded file is not a valid $kAppName backup.';
    }
    return bytes;
  }
}
