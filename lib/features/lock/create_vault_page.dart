import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import '../../core/crypto/vault_crypto.dart';
import '../../state/session.dart';
import '../../widgets/brand.dart';

class CreateVaultPage extends ConsumerStatefulWidget {
  const CreateVaultPage({super.key});

  @override
  ConsumerState<CreateVaultPage> createState() => _CreateVaultPageState();
}

class _CreateVaultPageState extends ConsumerState<CreateVaultPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  String? _localError;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _password.text;
    if (password.length < 8) {
      setState(() => _localError = 'Use at least 8 characters.');
      return;
    }
    if (password != _confirm.text) {
      setState(() => _localError = 'Passwords do not match.');
      return;
    }
    setState(() => _localError = null);
    await ref.read(sessionProvider.notifier).createVault(password);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final score = VaultCrypto.passwordScore(_password.text);
    final error = _localError ?? session.message;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          children: [
            const AmanahMark(),
            const SizedBox(height: 20),
            Text(
              'Create your vault',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$kAppName encrypts everything on this phone. There is no account and no password reset. Remember this master password.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Master password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            PasswordStrengthBar(score: score),
            const SizedBox(height: 16),
            TextField(
              controller: _confirm,
              obscureText: _obscure,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Confirm password',
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton(
              onPressed: session.busy ? null : _submit,
              child: session.busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create vault'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: SystemNavigator.pop,
              child: const Text('Exit App'),
            ),
          ],
        ),
      ),
    );
  }
}
