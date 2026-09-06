import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import '../../state/session.dart';
import '../../widgets/brand.dart';

class RecoveryPhrasePage extends ConsumerStatefulWidget {
  const RecoveryPhrasePage({super.key});

  @override
  ConsumerState<RecoveryPhrasePage> createState() => _RecoveryPhrasePageState();
}

class _RecoveryPhrasePageState extends ConsumerState<RecoveryPhrasePage> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final phrase = ref.watch(sessionProvider).recoveryPhrase ?? '';
    final words = phrase.split(' ');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            const AmanahMark(size: 64),
            const SizedBox(height: 20),
            Text(
              'Write down your recovery phrase',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'If you forget the master password, these 16 words are the only way to open this vault. Store them offline. $kAppName cannot reset them.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < words.length; i++)
                      Chip(label: Text('${i + 1}. ${words[i]}')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _saved,
              onChanged: (value) => setState(() => _saved = value ?? false),
              title: const Text('I wrote these words down in a safe place'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saved
                  ? () => ref.read(sessionProvider.notifier).confirmRecoveryPhrase()
                  : null,
              child: const Text('Continue to vault'),
            ),
          ],
        ),
      ),
    );
  }
}
