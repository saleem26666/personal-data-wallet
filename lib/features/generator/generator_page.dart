import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/crypto/password_generator.dart';
import '../../core/crypto/vault_crypto.dart';
import '../../state/session.dart';
import '../../widgets/brand.dart';

class GeneratorPage extends ConsumerStatefulWidget {
  const GeneratorPage({super.key});

  @override
  ConsumerState<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends ConsumerState<GeneratorPage> {
  final _generator = PasswordGenerator();
  GeneratorOptions _options = const GeneratorOptions();
  late String _value = _generator.generate(_options);

  void _regen() {
    _value = _generator.generate(_options);
  }

  void _refresh() {
    setState(_regen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generator')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SelectableText(
                    _value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  PasswordStrengthBar(score: VaultCrypto.passwordScore(_value)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    await ref.read(clipboardProvider).copy(_value);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied · clipboard clears in 30 seconds'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Passphrase'),
            subtitle: const Text('Memorable words instead of characters'),
            value: _options.passphrase,
            onChanged: (value) {
              setState(() {
                _options = _options.copyWith(passphrase: value);
                _regen();
              });
            },
          ),
          if (_options.passphrase)
            ListTile(
              title: Text('Words: ${_options.wordCount}'),
              subtitle: Slider(
                min: 3,
                max: 8,
                divisions: 5,
                value: _options.wordCount.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _options = _options.copyWith(wordCount: value.round());
                    _regen();
                  });
                },
              ),
            )
          else ...[
            ListTile(
              title: Text('Length: ${_options.length}'),
              subtitle: Slider(
                min: 8,
                max: 64,
                divisions: 56,
                value: _options.length.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _options = _options.copyWith(length: value.round());
                    _regen();
                  });
                },
              ),
            ),
            CheckboxListTile(
              title: const Text('Lowercase'),
              value: _options.lowercase,
              onChanged: (value) => _toggle(
                lowercase: value ?? true,
              ),
            ),
            CheckboxListTile(
              title: const Text('Uppercase'),
              value: _options.uppercase,
              onChanged: (value) => _toggle(uppercase: value ?? true),
            ),
            CheckboxListTile(
              title: const Text('Digits'),
              value: _options.digits,
              onChanged: (value) => _toggle(digits: value ?? true),
            ),
            CheckboxListTile(
              title: const Text('Symbols'),
              value: _options.symbols,
              onChanged: (value) => _toggle(symbols: value ?? true),
            ),
          ],
        ],
      ),
    );
  }

  void _toggle({
    bool? lowercase,
    bool? uppercase,
    bool? digits,
    bool? symbols,
  }) {
    final next = _options.copyWith(
      lowercase: lowercase,
      uppercase: uppercase,
      digits: digits,
      symbols: symbols,
    );
    if (!next.lowercase &&
        !next.uppercase &&
        !next.digits &&
        !next.symbols) {
      return;
    }
    setState(() {
      _options = next;
      _regen();
    });
  }
}
