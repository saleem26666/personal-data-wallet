import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/app_info.dart';
import '../core/categories.dart';
import '../core/clipboard_service.dart';
import '../core/crypto/vault_crypto.dart';
import '../data/database.dart';
import '../data/vault_files.dart';
import 'settings.dart';

enum SessionPhase {
  booting,
  needsSetup,
  locked,
  unlocking,
  recoverySetup,
  unlocked,
}

class SessionState {
  const SessionState({
    required this.phase,
    this.db,
    this.message,
    this.busy = false,
    this.recoveryPhrase,
    this.hasRecovery = false,
  });

  final SessionPhase phase;
  final VaultDatabase? db;
  final String? message;
  final bool busy;
  final String? recoveryPhrase;
  final bool hasRecovery;

  bool get isUnlocked =>
      (phase == SessionPhase.unlocked || phase == SessionPhase.recoverySetup) &&
      db != null;
}

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._files, this._settings)
      : super(const SessionState(phase: SessionPhase.booting)) {
    bootstrap();
  }

  final VaultFiles _files;
  final SettingsController _settings;
  final VaultCrypto _crypto = VaultCrypto();
  final LocalAuthentication _auth = LocalAuthentication();
  Uint8List? _vaultKey;

  Uint8List? get vaultKey => _vaultKey;

  Future<void> bootstrap() async {
    try {
      final exists = await _files.vaultExists();
      var hasRecovery = false;
      if (exists) {
        hasRecovery = (await _files.loadMeta()).recovery != null;
      }
      state = SessionState(
        phase: exists ? SessionPhase.locked : SessionPhase.needsSetup,
        hasRecovery: hasRecovery,
      );
    } catch (error) {
      state = SessionState(
        phase: SessionPhase.needsSetup,
        message: error.toString(),
      );
    }
  }

  Future<void> createVault(String masterPassword) async {
    state = state.copy(busy: true, message: null);
    try {
      final vaultKey = _crypto.newVaultKey();
      final phrase = _crypto.newRecoveryPhrase();
      final passwordWrap = await _crypto.wrapKey(
        vaultKey: vaultKey,
        masterPassword: masterPassword,
      );
      final recoveryWrap = await _crypto.wrapKey(
        vaultKey: vaultKey,
        masterPassword: VaultCrypto.normalizePhrase(phrase),
      );
      await _files.saveMeta(
        VaultMeta(password: passwordWrap, recovery: recoveryWrap),
      );
      final db = await VaultDatabase.open(vaultKey);
      _vaultKey = vaultKey;
      state = SessionState(
        phase: SessionPhase.recoverySetup,
        db: db,
        recoveryPhrase: phrase,
        hasRecovery: true,
      );
    } catch (error) {
      state = SessionState(
        phase: SessionPhase.needsSetup,
        message: error.toString(),
      );
    }
  }

  void confirmRecoveryPhrase() {
    state = SessionState(
      phase: SessionPhase.unlocked,
      db: state.db,
      hasRecovery: true,
    );
  }

  Future<void> unlockWithPassword(String masterPassword) async {
    state = SessionState(
      phase: SessionPhase.unlocking,
      busy: true,
      hasRecovery: state.hasRecovery,
    );
    try {
      final wrapped = await _files.loadWrappedKey();
      final vaultKey = await _crypto.unwrapKey(
        wrapped: wrapped,
        masterPassword: masterPassword,
      );
      await _open(vaultKey);
    } on VaultCryptoException catch (error) {
      state = SessionState(
        phase: SessionPhase.locked,
        message: error.message,
        hasRecovery: state.hasRecovery,
      );
    } catch (error) {
      state = SessionState(
        phase: SessionPhase.locked,
        message: error.toString(),
        hasRecovery: state.hasRecovery,
      );
    }
  }

  Future<void> unlockWithRecovery(String phrase) async {
    state = SessionState(
      phase: SessionPhase.unlocking,
      busy: true,
      hasRecovery: true,
    );
    try {
      final recovery = (await _files.loadMeta()).recovery;
      if (recovery == null) {
        throw const VaultCryptoException('No recovery phrase is set on this vault.');
      }
      final vaultKey = await _crypto.unwrapKey(
        wrapped: recovery,
        masterPassword: VaultCrypto.normalizePhrase(phrase),
        errorMessage: 'Wrong recovery phrase.',
      );
      await _open(vaultKey);
    } on VaultCryptoException catch (error) {
      state = SessionState(
        phase: SessionPhase.locked,
        message: error.message,
        hasRecovery: true,
      );
    } catch (error) {
      state = SessionState(
        phase: SessionPhase.locked,
        message: error.toString(),
        hasRecovery: true,
      );
    }
  }

  Future<bool> canUseBiometrics() async {
    if (!_settings.state.biometricEnabled) return false;
    final supported = await _auth.isDeviceSupported();
    final key = await _files.loadBiometricKey();
    return supported && key != null;
  }

  Future<void> unlockWithBiometrics() async {
    state = SessionState(
      phase: SessionPhase.unlocking,
      busy: true,
      hasRecovery: state.hasRecovery,
    );
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock $kAppName',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );
      if (!ok) {
        state = SessionState(
          phase: SessionPhase.locked,
          hasRecovery: state.hasRecovery,
        );
        return;
      }
      final key = await _files.loadBiometricKey();
      if (key == null) {
        state = SessionState(
          phase: SessionPhase.locked,
          message: 'Unlock with your password once, then turn biometric unlock back on.',
          hasRecovery: state.hasRecovery,
        );
        return;
      }
      await _open(key);
    } on PlatformException catch (error) {
      state = SessionState(
        phase: SessionPhase.locked,
        message: _biometricErrorMessage(error),
        hasRecovery: state.hasRecovery,
      );
    } catch (error) {
      state = SessionState(
        phase: SessionPhase.locked,
        message: _biometricErrorMessage(error),
        hasRecovery: state.hasRecovery,
      );
    }
  }

  Future<void> enableBiometrics(bool enabled) async {
    if (!enabled) {
      await _files.clearBiometricKey();
      await _settings.setBiometricEnabled(false);
      return;
    }
    final key = _vaultKey;
    if (key == null) return;
    final ok = await _auth.authenticate(
      localizedReason: 'Allow fingerprint unlock for $kAppName',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
        useErrorDialogs: true,
        sensitiveTransaction: false,
      ),
    );
    if (!ok) return;
    await _files.saveBiometricKey(key);
    await _settings.setBiometricEnabled(true);
  }

  Future<void> changeMasterPassword({
    required String currentPassword,
    required String nextPassword,
  }) async {
    final meta = await _files.loadMeta();
    final vaultKey = await _crypto.unwrapKey(
      wrapped: meta.password,
      masterPassword: currentPassword,
    );
    final next = await _crypto.wrapKey(
      vaultKey: vaultKey,
      masterPassword: nextPassword,
    );
    await _files.saveMeta(VaultMeta(password: next, recovery: meta.recovery));
    if (_settings.state.biometricEnabled) {
      await _files.saveBiometricKey(vaultKey);
    }
  }

  Future<String> addRecoveryPhrase() async {
    final key = _vaultKey;
    if (key == null) {
      throw const VaultCryptoException('Unlock the vault first.');
    }
    final phrase = _crypto.newRecoveryPhrase();
    final meta = await _files.loadMeta();
    final recovery = await _crypto.wrapKey(
      vaultKey: key,
      masterPassword: VaultCrypto.normalizePhrase(phrase),
    );
    await _files.saveMeta(VaultMeta(password: meta.password, recovery: recovery));
    state = SessionState(
      phase: state.phase,
      db: state.db,
      hasRecovery: true,
    );
    return phrase;
  }

  Future<Uint8List> exportBackup() async {
    final key = _vaultKey;
    if (key == null) {
      throw const VaultCryptoException('Unlock the vault first.');
    }
    await state.db?.close();
    try {
      return _files.zipVault();
    } finally {
      await _open(key);
    }
  }

  /// Builds a new vault that only contains [categoryIds], wrapped with
  /// [sharePassword]. Recipient restores it like a normal backup.
  Future<Uint8List> exportSplitBackup({
    required Set<String> categoryIds,
    required String sharePassword,
  }) async {
    final sourceKey = _vaultKey;
    final sourceDb = state.db;
    if (sourceKey == null || sourceDb == null) {
      throw const VaultCryptoException('Unlock the vault first.');
    }
    if (categoryIds.isEmpty) {
      throw const VaultCryptoException('Pick at least one category.');
    }
    if (sharePassword.length < 8) {
      throw const VaultCryptoException(
        'Share password must be at least 8 characters.',
      );
    }

    final all = await sourceDb.watchAll().first;
    final selected = [
      for (final item in all)
        if (categoryIds.contains(item.categoryId)) item,
    ];
    if (selected.isEmpty) {
      throw const VaultCryptoException('No records in the selected categories.');
    }

    final userCats = await sourceDb.allUserCategories();
    final shareKey = _crypto.newVaultKey();
    final wrapped = await _crypto.wrapKey(
      vaultKey: shareKey,
      masterPassword: sharePassword,
    );

    final docs = await getTemporaryDirectory();
    final splitDir = Directory(p.join(docs.path, 'amanah.split'));
    if (splitDir.existsSync()) {
      await splitDir.delete(recursive: true);
    }
    await splitDir.create(recursive: true);
    final attachmentsDir =
        Directory(p.join(splitDir.path, 'attachments'));
    await attachmentsDir.create(recursive: true);

    await File(p.join(splitDir.path, 'amanah.meta.json')).writeAsString(
      jsonEncode(VaultMeta(password: wrapped).toJson()),
    );

    final destDb = await VaultDatabase.openAt(
      File(p.join(splitDir.path, 'amanah.sqlite')),
      shareKey,
    );
    try {
      for (final row in userCats) {
        if (!categoryIds.contains(row.id)) continue;
        await destDb.saveUserCategory(
          id: row.id,
          label: row.label,
          subtitle: row.subtitle,
          iconCode: row.iconCode,
          colorValue: row.colorValue,
          fieldsJson: row.fieldsJson,
        );
      }
      for (final item in selected) {
        await destDb.upsertItem(
          id: item.item.id,
          categoryId: item.categoryId,
          title: item.item.title,
          notes: item.item.notes,
          tags: item.item.tags,
          favorite: item.item.favorite,
          fields: [
            for (final field in item.fields)
              VaultFieldsCompanion.insert(
                id: field.id,
                itemId: item.item.id,
                key: field.key,
                label: field.label,
                value: field.value,
                fieldType: field.fieldType,
                sortOrder: field.sortOrder,
                concealed: Value(field.concealed),
              ),
          ],
        );
        for (final attachment in item.attachments) {
          final clear = await loadScan(attachment.id);
          final packed = await _crypto.encryptBlob(shareKey, clear);
          await File(p.join(attachmentsDir.path, '${attachment.id}.bin'))
              .writeAsBytes(packed, flush: true);
          await destDb.addAttachment(
            id: attachment.id,
            itemId: item.item.id,
            label: attachment.label,
            createdAt: attachment.createdAt,
          );
        }
      }
    } finally {
      await destDb.close();
    }

    try {
      return await _files.zipDirectory(splitDir);
    } finally {
      if (splitDir.existsSync()) {
        await splitDir.delete(recursive: true);
      }
    }
  }

  Future<void> importBackup(Uint8List bytes) async {
    await lock();
    await _files.restoreZip(bytes);
    await _files.clearBiometricKey();
    await _settings.setBiometricEnabled(false);
    await bootstrap();
  }

  Future<VaultAttachment> saveScan({
    required String itemId,
    required String label,
    required Uint8List bytes,
  }) async {
    final key = _vaultKey;
    final db = state.db;
    if (key == null || db == null) {
      throw const VaultCryptoException('Unlock the vault first.');
    }
    final row = await db.addAttachment(itemId: itemId, label: label);
    final packed = await _crypto.encryptBlob(key, bytes);
    final file = await _files.attachmentFile(row.id);
    await file.writeAsBytes(packed, flush: true);
    await db.touch(itemId);
    return row;
  }

  Future<Uint8List> loadScan(String id) async {
    final key = _vaultKey;
    if (key == null) {
      throw const VaultCryptoException('Unlock the vault first.');
    }
    final packed = await (await _files.attachmentFile(id)).readAsBytes();
    return _crypto.decryptBlob(key, packed);
  }

  Future<void> removeScan(String id) async {
    await state.db?.deleteAttachment(id);
    final file = await _files.attachmentFile(id);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> deleteRecord(String id, {List<String> attachmentIds = const []}) async {
    for (final attachmentId in attachmentIds) {
      await removeScan(attachmentId);
    }
    await state.db?.deleteItem(id);
  }

  Future<void> deleteCategory(CategoryDef category) async {
    final db = state.db;
    if (db == null) return;
    final attachmentIds = await db.attachmentIdsInCategory(category.id);
    for (final attachmentId in attachmentIds) {
      final file = await _files.attachmentFile(attachmentId);
      if (file.existsSync()) {
        await file.delete();
      }
    }
    await db.deleteCategory(
      id: category.id,
      userDefined: category.userDefined,
    );
  }

  Future<void> restoreHiddenCategory(String id) async {
    await state.db?.restoreHiddenCategory(id);
  }

  Future<void> lock() async {
    final db = state.db;
    _vaultKey = null;
    if (db != null) {
      await db.close();
    }
    state = SessionState(
      phase: SessionPhase.locked,
      hasRecovery: state.hasRecovery,
    );
  }

  Future<void> destroyVault() async {
    await lock();
    await _files.destroy();
    await _settings.setBiometricEnabled(false);
    state = const SessionState(phase: SessionPhase.needsSetup);
  }

  Future<void> _open(Uint8List vaultKey) async {
    final db = await VaultDatabase.open(vaultKey);
    _vaultKey = vaultKey;
    final hasRecovery = (await _files.loadMeta()).recovery != null;
    state = SessionState(
      phase: SessionPhase.unlocked,
      db: db,
      hasRecovery: hasRecovery,
    );
  }

  String? _biometricErrorMessage(Object error) {
    final code = error is PlatformException ? error.code.toLowerCase() : '';
    final text = error.toString().toLowerCase();
    if (code.contains('cancel') ||
        text.contains('cancel') ||
        text.contains('notauthenticated')) {
      return null;
    }
    if (code.contains('lockedout') || text.contains('lockout')) {
      return 'Too many fingerprint attempts. Unlock with your password, then try again.';
    }
    if (code.contains('fragment') ||
        text.contains('no activity') ||
        text.contains('not available') ||
        text.contains('auth_in_progress')) {
      return 'Fingerprint is ready after the share or file screen closes. Use your password this time, or tap Use biometric.';
    }
    if (text.contains('error') && text.contains('platformexception')) {
      return 'Fingerprint could not run just now. Unlock with your password.';
    }
    return 'Fingerprint failed. Unlock with your password.';
  }
}

extension on SessionState {
  SessionState copy({
    SessionPhase? phase,
    VaultDatabase? db,
    String? message,
    bool? busy,
    String? recoveryPhrase,
    bool? hasRecovery,
  }) {
    return SessionState(
      phase: phase ?? this.phase,
      db: db ?? this.db,
      message: message,
      busy: busy ?? this.busy,
      recoveryPhrase: recoveryPhrase ?? this.recoveryPhrase,
      hasRecovery: hasRecovery ?? this.hasRecovery,
    );
  }
}

final vaultFilesProvider = Provider<VaultFiles>((ref) => VaultFiles());

final clipboardProvider = Provider<ClipboardService>((ref) {
  final seconds = ref.watch(settingsProvider).clipboardSeconds;
  final service = ClipboardService(clearAfter: Duration(seconds: seconds));
  ref.onDispose(service.dispose);
  return service;
});

final sessionProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(
    ref.watch(vaultFilesProvider),
    ref.watch(settingsProvider.notifier),
  );
});

final itemsProvider = StreamProvider<List<ItemWithFields>>((ref) {
  final session = ref.watch(sessionProvider);
  final db = session.db;
  if (db == null) {
    return Stream.value(const <ItemWithFields>[]);
  }
  return db.watchAll();
});

final userCategoriesProvider = StreamProvider<List<CategoryDef>>((ref) {
  final db = ref.watch(sessionProvider).db;
  if (db == null) {
    return Stream.value(const <CategoryDef>[]);
  }
  return db.watchUserCategories().map(
        (rows) => [
          for (final row in rows)
            CategoryDef(
              id: row.id,
              label: row.label,
              subtitle: row.subtitle,
              icon: iconFromStored(row.iconCode),
              color: Color(row.colorValue),
              fields: decodeFields(row.fieldsJson),
              userDefined: true,
            ),
        ],
      );
});

final hiddenCategoryIdsProvider = StreamProvider<Set<String>>((ref) {
  final db = ref.watch(sessionProvider).db;
  if (db == null) {
    return Stream.value(const <String>{});
  }
  return db.watchHiddenCategoryIds();
});

final catalogProvider = Provider<List<CategoryDef>>((ref) {
  final user = ref.watch(userCategoriesProvider).valueOrNull ?? const [];
  final hidden =
      ref.watch(hiddenCategoryIdsProvider).valueOrNull ?? const <String>{};
  final seen = <String>{};
  final catalog = <CategoryDef>[];
  for (final category in [...builtInCategories, ...user]) {
    if (hidden.contains(category.id) || !seen.add(category.id)) continue;
    catalog.add(category);
  }
  return catalog;
});
