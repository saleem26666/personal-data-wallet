import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/crypto/vault_crypto.dart';

class VaultMeta {
  const VaultMeta({required this.password, this.recovery});

  final WrappedVaultKey password;
  final WrappedVaultKey? recovery;

  Map<String, dynamic> toJson() => {
        'version': 2,
        'password': password.toJson(),
        if (recovery != null) 'recovery': recovery!.toJson(),
      };

  factory VaultMeta.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('salt')) {
      return VaultMeta(password: WrappedVaultKey.fromJson(json));
    }
    return VaultMeta(
      password: WrappedVaultKey.fromJson(
        json['password'] as Map<String, dynamic>,
      ),
      recovery: json['recovery'] == null
          ? null
          : WrappedVaultKey.fromJson(json['recovery'] as Map<String, dynamic>),
    );
  }
}

class VaultFiles {
  static const _biometricKey = 'amanah.biometric.vaultKey';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<Directory> root() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'amanah'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> attachmentsDir() async {
    final dir = Directory(p.join((await root()).path, 'attachments'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> attachmentFile(String id) async {
    return File(p.join((await attachmentsDir()).path, '$id.bin'));
  }

  Future<File> metaFile() async {
    return File(p.join((await root()).path, 'amanah.meta.json'));
  }

  Future<bool> vaultExists() async {
    final meta = await metaFile();
    return meta.exists();
  }

  Future<void> saveMeta(VaultMeta meta) async {
    final file = await metaFile();
    await file.writeAsString(jsonEncode(meta.toJson()));
  }

  Future<VaultMeta> loadMeta() async {
    final file = await metaFile();
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return VaultMeta.fromJson(json);
  }

  Future<void> saveWrappedKey(WrappedVaultKey wrapped) async {
    VaultMeta? existing;
    try {
      existing = await loadMeta();
    } catch (_) {}
    await saveMeta(
      VaultMeta(password: wrapped, recovery: existing?.recovery),
    );
  }

  Future<WrappedVaultKey> loadWrappedKey() async {
    return (await loadMeta()).password;
  }

  Future<void> saveBiometricKey(Uint8List vaultKey) {
    return _storage.write(
      key: _biometricKey,
      value: base64Encode(vaultKey),
    );
  }

  Future<Uint8List?> loadBiometricKey() async {
    final value = await _storage.read(key: _biometricKey);
    if (value == null) return null;
    return Uint8List.fromList(base64Decode(value));
  }

  Future<void> clearBiometricKey() {
    return _storage.delete(key: _biometricKey);
  }

  bool _isSqliteSidecar(String relative) {
    return relative.endsWith('-wal') ||
        relative.endsWith('-shm') ||
        relative.endsWith('-journal');
  }

  Future<Uint8List> zipVault() async {
    return zipDirectory(await root());
  }

  Future<Uint8List> zipDirectory(Directory dir) async {
    final archive = Archive();
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relative =
          p.relative(entity.path, from: dir.path).replaceAll('\\', '/');
      if (_isSqliteSidecar(relative)) continue;
      final bytes = await entity.readAsBytes();
      archive.addFile(ArchiveFile(relative, bytes.length, bytes));
    }
    final zip = ZipEncoder().encodeBytes(
      archive,
      level: DeflateLevel.bestCompression,
    );
    return Uint8List.fromList(
      GZipEncoder().encodeBytes(zip, level: DeflateLevel.bestCompression),
    );
  }

  Future<void> restoreZip(Uint8List bytes) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(_unwrapBackup(bytes));
    } catch (_) {
      throw const VaultCryptoException('This file is not an Amanaat backup.');
    }
    final hasMeta = archive.files.any((file) {
      if (!file.isFile) return false;
      final name = file.name.replaceAll('\\', '/');
      return name == 'amanah.meta.json' || name.endsWith('/amanah.meta.json');
    });
    if (!hasMeta) {
      throw const VaultCryptoException('This file is not an Amanaat backup.');
    }

    final dir = await root();
    final parent = dir.parent;
    final staging = Directory(p.join(parent.path, 'amanah.incoming'));
    final outgoing = Directory(p.join(parent.path, 'amanah.outgoing'));
    if (staging.existsSync()) {
      await staging.delete(recursive: true);
    }
    await staging.create(recursive: true);
    try {
      for (final file in archive.files) {
        if (!file.isFile) continue;
        if (_isSqliteSidecar(file.name)) continue;
        final out = File(p.join(staging.path, file.name));
        await out.parent.create(recursive: true);
        await out.writeAsBytes(file.content as List<int>);
      }
      if (outgoing.existsSync()) {
        await outgoing.delete(recursive: true);
      }
      if (dir.existsSync()) {
        await dir.rename(outgoing.path);
      }
      try {
        await staging.rename(dir.path);
      } catch (_) {
        if (outgoing.existsSync() && !dir.existsSync()) {
          await outgoing.rename(dir.path);
        }
        rethrow;
      }
      if (outgoing.existsSync()) {
        await outgoing.delete(recursive: true);
      }
    } catch (error) {
      if (staging.existsSync()) {
        await staging.delete(recursive: true);
      }
      if (error is VaultCryptoException) rethrow;
      throw VaultCryptoException(error.toString());
    }
  }

  Uint8List _unwrapBackup(Uint8List bytes) {
    if (bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
      return Uint8List.fromList(GZipDecoder().decodeBytes(bytes));
    }
    return bytes;
  }

  Future<void> destroy() async {
    final dir = await root();
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    await _storage.deleteAll();
  }
}
