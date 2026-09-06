import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:amanah/core/crypto/password_generator.dart';
import 'package:amanah/core/crypto/vault_crypto.dart';

void main() {
  test('wrap and unwrap vault key with master password', () async {
    final crypto = VaultCrypto();
    const password = 'correct-horse-battery';
    final key = crypto.newVaultKey();
    final wrapped = await crypto.wrapKey(vaultKey: key, masterPassword: password);
    final opened = await crypto.unwrapKey(wrapped: wrapped, masterPassword: password);
    expect(opened, key);
  });

  test('wrong master password fails closed', () async {
    final crypto = VaultCrypto();
    final wrapped = await crypto.wrapKey(
      vaultKey: crypto.newVaultKey(),
      masterPassword: 'real-password-here',
    );
    expect(
      () => crypto.unwrapKey(wrapped: wrapped, masterPassword: 'nope'),
      throwsA(isA<VaultCryptoException>()),
    );
  });

  test('generator respects length and passphrase', () {
    final generator = PasswordGenerator();
    final secret = generator.generate(const GeneratorOptions(length: 24));
    expect(secret.length, 24);
    final phrase = generator.generate(
      const GeneratorOptions(passphrase: true, wordCount: 5),
    );
    expect(phrase.split('-'), hasLength(5));
  });

  test('password score increases with complexity', () {
    expect(VaultCrypto.passwordScore(''), 0);
    expect(VaultCrypto.passwordScore('abcdefghijkl'), greaterThan(0));
    expect(
      VaultCrypto.passwordScore('Abcdefghijk1!'),
      greaterThan(VaultCrypto.passwordScore('short')),
    );
  });

  test('blob encrypt roundtrip', () async {
    final crypto = VaultCrypto();
    final key = crypto.newVaultKey();
    const payload = [1, 2, 3, 4, 5];
    final packed = await crypto.encryptBlob(key, Uint8List.fromList(payload));
    final clear = await crypto.decryptBlob(key, packed);
    expect(clear, payload);
  });
}
