import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_info.dart';
import 'core/incoming_share.dart';
import 'core/theme.dart';
import 'features/home/shell.dart';
import 'features/lock/create_vault_page.dart';
import 'features/lock/recovery_phrase_page.dart';
import 'features/lock/unlock_page.dart';
import 'features/settings/backup_restore.dart';
import 'state/lock_hold.dart';
import 'state/session.dart';
import 'state/settings.dart';
import 'widgets/brand.dart';

class AmanahApp extends ConsumerWidget {
  const AmanahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeName = ref.watch(settingsProvider).themeModeName;
    final themeMode = switch (themeModeName) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AmanahTheme.light(),
      darkTheme: AmanahTheme.dark(),
      themeMode: themeMode,
      home: const AutoLockGate(),
    );
  }
}

class AutoLockGate extends ConsumerStatefulWidget {
  const AutoLockGate({super.key});

  @override
  ConsumerState<AutoLockGate> createState() => _AutoLockGateState();
}

class _AutoLockGateState extends ConsumerState<AutoLockGate>
    with WidgetsBindingObserver {
  Timer? _idle;
  ProviderSubscription<SessionState>? _sessionSub;
  StreamSubscription<String>? _incomingSub;
  String? _lastIncomingPath;
  var _handlingIncoming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionSub = ref.listenManual(sessionProvider, (previous, next) {
      if (next.isUnlocked) _bumpIdle();
    });
    _incomingSub = IncomingShare.files.listen(_onIncomingFile);
    IncomingShare.takePending().then((path) {
      if (path != null) _onIncomingFile(path);
    }).catchError((_) {});
    _bumpIdle();
  }

  @override
  void dispose() {
    _incomingSub?.cancel();
    _sessionSub?.close();
    WidgetsBinding.instance.removeObserver(this);
    _idle?.cancel();
    super.dispose();
  }

  Future<void> _onIncomingFile(String path) async {
    if (path == _lastIncomingPath) return;
    _lastIncomingPath = path;
    if (_handlingIncoming) return;
    _handlingIncoming = true;
    try {
      while (mounted) {
        final phase = ref.read(sessionProvider).phase;
        if (phase != SessionPhase.booting &&
            phase != SessionPhase.unlocking) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 80));
      }
      if (!mounted) return;
      final bytes = await readIncomingFile(path);
      if (!mounted) return;
      if (bytes == null || !looksLikeAmanaatBackup(bytes)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This file is not an Amanaat backup.'),
          ),
        );
        return;
      }
      final ok = await confirmRestoreBackup(context);
      if (!ok || !mounted) return;
      await applyBackupBytes(context, ref, bytes);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      _handlingIncoming = false;
    }
  }

  void _bumpIdle() {
    _idle?.cancel();
    final settings = ref.read(settingsProvider);
    final session = ref.read(sessionProvider);
    if (!session.isUnlocked) return;
    _idle = Timer(Duration(seconds: settings.idleLockSeconds), () {
      ref.read(sessionProvider.notifier).lock();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused) return;
    if (ref.read(lockHoldCountProvider) > 0) return;
    final session = ref.read(sessionProvider);
    if (session.phase == SessionPhase.unlocking) return;
    final settings = ref.read(settingsProvider);
    if (settings.lockOnBackground && session.isUnlocked) {
      ref.read(sessionProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    return Listener(
      onPointerDown: (_) => _bumpIdle(),
      onPointerMove: (_) => _bumpIdle(),
      child: switch (session.phase) {
        SessionPhase.booting || SessionPhase.unlocking => const _BootScreen(),
        SessionPhase.needsSetup => const CreateVaultPage(),
        SessionPhase.locked => const UnlockPage(),
        SessionPhase.recoverySetup => const RecoveryPhrasePage(),
        SessionPhase.unlocked => const AppShell(),
      },
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AmanahMark(size: 72),
            const SizedBox(height: 16),
            Text(
              kAppName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
