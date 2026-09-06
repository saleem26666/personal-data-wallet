import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import '../../state/session.dart';
import '../../widgets/brand.dart';

class UnlockPage extends ConsumerStatefulWidget {
  const UnlockPage({super.key});

  @override
  ConsumerState<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends ConsumerState<UnlockPage>
    with WidgetsBindingObserver {
  final _password = TextEditingController();
  bool _obscure = true;
  bool _biometrics = false;
  bool _autoTried = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryAutoBiometric());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _password.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tryAutoBiometric();
    }
  }

  Future<void> _tryAutoBiometric() async {
    if (_autoTried || !mounted) return;
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    _autoTried = true;
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    final can = await ref.read(sessionProvider.notifier).canUseBiometrics();
    if (!mounted) return;
    setState(() => _biometrics = can);
    if (can) {
      await ref.read(sessionProvider.notifier).unlockWithBiometrics();
    }
  }

  Future<void> _recovery(BuildContext context) async {
    final phrase = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recovery phrase'),
        content: TextField(
          controller: phrase,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter your 16 words',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(sessionProvider.notifier).unlockWithRecovery(phrase.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
          child: Column(
            children: [
              const AmanahMark(),
              const SizedBox(height: 20),
              Text(
                kAppName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your data. Your key.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              TextField(
                controller: _password,
                obscureText: _obscure,
                autofocus: !_biometrics,
                onSubmitted: (_) {
                  ref
                      .read(sessionProvider.notifier)
                      .unlockWithPassword(_password.text);
                },
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
              if (session.message != null) ...[
                const SizedBox(height: 12),
                Text(
                  session.message!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: session.busy
                    ? null
                    : () => ref
                        .read(sessionProvider.notifier)
                        .unlockWithPassword(_password.text),
                child: const Text('Unlock'),
              ),
              if (_biometrics) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: session.busy
                      ? null
                      : () => ref
                          .read(sessionProvider.notifier)
                          .unlockWithBiometrics(),
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use biometric'),
                ),
              ],
              if (session.hasRecovery)
                TextButton(
                  onPressed: session.busy ? null : () => _recovery(context),
                  child: const Text('Forgot password? Use recovery phrase'),
                ),
              TextButton(
                onPressed: SystemNavigator.pop,
                child: Text(
                  'Exit App',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
