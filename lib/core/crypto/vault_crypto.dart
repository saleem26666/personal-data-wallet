import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'password_generator.dart';

class WrappedVaultKey {
  const WrappedVaultKey({
    required this.version,
    required this.memoryKib,
    required this.iterations,
    required this.parallelism,
    required this.salt,
    required this.nonce,
    required this.mac,
    required this.cipher,
  });

  final int version;
  final int memoryKib;
  final int iterations;
  final int parallelism;
  final Uint8List salt;
  final Uint8List nonce;
  final Uint8List mac;
  final Uint8List cipher;

  Map<String, dynamic> toJson() => {
        'version': version,
        'kdf': 'argon2id',
        'memoryKib': memoryKib,
        'iterations': iterations,
        'parallelism': parallelism,
        'salt': base64Encode(salt),
        'nonce': base64Encode(nonce),
        'mac': base64Encode(mac),
        'cipher': base64Encode(cipher),
      };

  factory WrappedVaultKey.fromJson(Map<String, dynamic> json) {
    return WrappedVaultKey(
      version: json['version'] as int,
      memoryKib: json['memoryKib'] as int,
      iterations: json['iterations'] as int,
      parallelism: json['parallelism'] as int,
      salt: Uint8List.fromList(base64Decode(json['salt'] as String)),
      nonce: Uint8List.fromList(base64Decode(json['nonce'] as String)),
      mac: Uint8List.fromList(base64Decode(json['mac'] as String)),
      cipher: Uint8List.fromList(base64Decode(json['cipher'] as String)),
    );
  }
}

class VaultCryptoException implements Exception {
  const VaultCryptoException(this.message);
  final String message;
  @override
  String toString() => message;
}

class VaultCrypto {
  VaultCrypto({Random? random}) : _random = random ?? Random.secure();

  static const currentVersion = 1;
  static const defaultMemoryKib = 16384;
  static const defaultIterations = 2;
  static const defaultParallelism = 1;
  static const keyLength = 32;

  final Random _random;

  Uint8List randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }

  Uint8List newVaultKey() => randomBytes(keyLength);

  Argon2id _argon2({
    required int memoryKib,
    required int iterations,
    required int parallelism,
  }) {
    return Argon2id(
      parallelism: parallelism,
      memory: memoryKib,
      iterations: iterations,
      hashLength: keyLength,
    );
  }

  Future<SecretKey> deriveKek(
    String masterPassword,
    Uint8List salt, {
    int memoryKib = defaultMemoryKib,
    int iterations = defaultIterations,
    int parallelism = defaultParallelism,
  }) {
    return _argon2(
      memoryKib: memoryKib,
      iterations: iterations,
      parallelism: parallelism,
    ).deriveKeyFromPassword(
      password: masterPassword,
      nonce: salt,
    );
  }

  Future<WrappedVaultKey> wrapKey({
    required Uint8List vaultKey,
    required String masterPassword,
  }) async {
    final salt = randomBytes(16);
    final kek = await deriveKek(masterPassword, salt);
    final box = await AesGcm.with256bits().encrypt(
      vaultKey,
      secretKey: kek,
    );
    return WrappedVaultKey(
      version: currentVersion,
      memoryKib: defaultMemoryKib,
      iterations: defaultIterations,
      parallelism: defaultParallelism,
      salt: salt,
      nonce: Uint8List.fromList(box.nonce),
      mac: Uint8List.fromList(box.mac.bytes),
      cipher: Uint8List.fromList(box.cipherText),
    );
  }

  Future<Uint8List> unwrapKey({
    required WrappedVaultKey wrapped,
    required String masterPassword,
    String errorMessage = 'Wrong master password.',
  }) async {
    try {
      final kek = await deriveKek(
        masterPassword,
        wrapped.salt,
        memoryKib: wrapped.memoryKib,
        iterations: wrapped.iterations,
        parallelism: wrapped.parallelism,
      );
      final clear = await AesGcm.with256bits().decrypt(
        SecretBox(
          wrapped.cipher,
          nonce: wrapped.nonce,
          mac: Mac(wrapped.mac),
        ),
        secretKey: kek,
      );
      return Uint8List.fromList(clear);
    }     on SecretBoxAuthenticationError {
      throw VaultCryptoException(errorMessage);
    }
  }

  Future<Uint8List> encryptBlob(Uint8List vaultKey, Uint8List data) async {
    final box = await AesGcm.with256bits().encrypt(
      data,
      secretKey: SecretKey(vaultKey),
    );
    return Uint8List.fromList([
      ...box.nonce,
      ...box.mac.bytes,
      ...box.cipherText,
    ]);
  }

  Future<Uint8List> decryptBlob(Uint8List vaultKey, Uint8List packed) async {
    if (packed.length < 28) {
      throw const VaultCryptoException('Attachment is corrupted.');
    }
    final nonce = packed.sublist(0, 12);
    final mac = packed.sublist(12, 28);
    final cipher = packed.sublist(28);
    try {
      final clear = await AesGcm.with256bits().decrypt(
        SecretBox(cipher, nonce: nonce, mac: Mac(mac)),
        secretKey: SecretKey(vaultKey),
      );
      return Uint8List.fromList(clear);
    } on SecretBoxAuthenticationError {
      throw const VaultCryptoException('Could not decrypt attachment.');
    }
  }

  String newRecoveryPhrase() {
    return List<String>.generate(
      16,
      (_) => PasswordGenerator.words[_random.nextInt(PasswordGenerator.words.length)],
    ).join(' ');
  }

  static String normalizePhrase(String phrase) {
    return phrase.trim().toLowerCase().split(RegExp(r'\s+')).join(' ');
  }

  static int passwordScore(String password) {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]'))) {
      score++;
    }
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return score.clamp(0, 4);
  }
}

String vaultKeyToPragma(Uint8List key) => base64UrlEncode(key);

String escapeSqlLiteral(String value) => value.replaceAll("'", "''");
