import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_info.dart';
import '../../core/categories.dart';
import '../../services/google_drive_backup_service.dart';
import '../../state/lock_hold.dart';
import '../../state/session.dart';
import '../../state/settings.dart';
import 'backup_restore.dart';
import 'category_actions.dart';
import 'category_editor_page.dart';
import 'split_backup_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionLabel('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'system', label: Text('System')),
                ButtonSegment(value: 'light', label: Text('Light')),
                ButtonSegment(value: 'dark', label: Text('Dark')),
              ],
              selected: {settings.themeModeName},
              onSelectionChanged: (value) {
                ref.read(settingsProvider.notifier).setThemeMode(value.first);
              },
            ),
          ),
          const _SectionLabel('Security'),
          SwitchListTile(
            title: const Text('Lock when app is in background'),
            value: settings.lockOnBackground,
            onChanged: ref.read(settingsProvider.notifier).setLockOnBackground,
          ),
          ListTile(
            title: const Text('Auto-lock after idle'),
            subtitle: Text(_idleLabel(settings.idleLockSeconds)),
            onTap: () => _pickIdle(context, ref, settings.idleLockSeconds),
          ),
          SwitchListTile(
            title: const Text('Biometric unlock'),
            subtitle: const Text('Fingerprint or face after first password unlock'),
            value: settings.biometricEnabled,
            onChanged: (value) async {
              final auth = LocalAuthentication();
              if (value && !await auth.isDeviceSupported()) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Biometrics are not available.')),
                  );
                }
                return;
              }
              await ref.read(sessionProvider.notifier).enableBiometrics(value);
            },
          ),
          ListTile(
            title: const Text('Change master password'),
            onTap: () => _changePassword(context, ref),
          ),
          if (!ref.watch(sessionProvider).hasRecovery)
            ListTile(
              title: const Text('Add recovery phrase'),
              subtitle: const Text('Needed if you forget the master password'),
              onTap: () => _addRecovery(context, ref),
            ),
          ListTile(
            title: const Text('Lock now'),
            leading: const Icon(Icons.lock_outline),
            onTap: () => ref.read(sessionProvider.notifier).lock(),
          ),
          ListTile(
            title: const Text('Exit App'),
            leading: const Icon(Icons.power_settings_new_rounded),
            onTap: SystemNavigator.pop,
          ),
          const _SectionLabel('Categories'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Delete a built-in or custom category from here. If it has records, you will be asked first.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final category in ref.watch(catalogProvider))
            ListTile(
              leading: CircleAvatar(
                backgroundColor: category.color.withValues(alpha: 0.18),
                child: Icon(category.icon, color: category.color),
              ),
              title: Text(category.label),
              subtitle: Text(
                category.userDefined
                    ? category.fields.map((field) => field.label).join(', ')
                    : category.subtitle,
              ),
              trailing: IconButton(
                tooltip: 'Delete',
                onPressed: () =>
                    confirmAndDeleteCategory(context, ref, category),
                icon: const Icon(Icons.delete_outline),
              ),
              onTap: category.userDefined
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              CategoryEditorPage(existing: category),
                        ),
                      );
                    }
                  : null,
            ),
          ..._hiddenCategoryTiles(context, ref),
          ListTile(
            leading: const Icon(Icons.add_box_outlined),
            title: const Text('Add category'),
            subtitle: const Text('Name, icon, and your own fields'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CategoryEditorPage(),
                ),
              );
            },
          ),
          const _SectionLabel('Google Drive'),
          const _GoogleDriveBackupSection(),
          const _SectionLabel('Backup'),
          ListTile(
            title: const Text('Export encrypted backup'),
            subtitle: const Text(
              'Compressed vault file — share on WhatsApp or email',
            ),
            leading: const Icon(Icons.file_upload_outlined),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            title: const Text('Restore backup'),
            subtitle: const Text(
              'Pick a file, or open it from WhatsApp and choose Amanaat',
            ),
            leading: const Icon(Icons.file_download_outlined),
            onTap: () => _import(context, ref),
          ),
          ListTile(
            title: const Text('Family split backup'),
            subtitle: const Text(
              'Export only Bank, IDs, or any categories you pick',
            ),
            leading: const Icon(Icons.group_outlined),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SplitBackupPage(),
                ),
              );
            },
          ),
          const _SectionLabel('Danger'),
          ListTile(
            title: Text(
              'Destroy vault',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Deletes all encrypted data on this phone'),
            onTap: () => _destroy(context, ref),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$kAppName 1.4.0 · Data stays on this device. Keep your recovery phrase offline.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _idleLabel(int seconds) {
    if (seconds < 60) return '$seconds seconds';
    final minutes = seconds ~/ 60;
    return minutes == 1 ? '1 minute' : '$minutes minutes';
  }

  Future<void> _pickIdle(BuildContext context, WidgetRef ref, int current) async {
    final value = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        const options = [30, 60, 120, 300, 600];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              ListTile(
                title: Text(_idleLabel(option)),
                trailing: option == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, option),
              ),
          ],
        );
      },
    );
    if (value != null) {
      await ref.read(settingsProvider.notifier).setIdleLockSeconds(value);
    }
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change master password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm new password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (next.text.length < 8 || next.text != confirm.text) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords must match and be 8+ characters.')),
        );
      }
      return;
    }
    try {
      await ref.read(sessionProvider.notifier).changeMasterPassword(
            currentPassword: current.text,
            nextPassword: next.text,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Master password updated.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  Future<void> _addRecovery(BuildContext context, WidgetRef ref) async {
    final phrase = await ref.read(sessionProvider.notifier).addRecoveryPhrase();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write these 16 words down'),
        content: SelectableText(phrase),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I saved them'),
          ),
        ],
      ),
    );
  }

  List<Widget> _hiddenCategoryTiles(BuildContext context, WidgetRef ref) {
    final hidden =
        ref.watch(hiddenCategoryIdsProvider).valueOrNull ?? const <String>{};
    if (hidden.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          'Hidden built-in categories',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      for (final category in builtInCategories)
        if (hidden.contains(category.id))
          ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color.withValues(alpha: 0.18),
              child: Icon(category.icon, color: category.color),
            ),
            title: Text(category.label),
            subtitle: const Text('Removed from Home'),
            trailing: TextButton(
              onPressed: () async {
                await ref
                    .read(sessionProvider.notifier)
                    .restoreHiddenCategory(category.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${category.label} restored.')),
                  );
                }
              },
              child: const Text('Restore'),
            ),
          ),
    ];
  }

  Future<void> _destroy(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Destroy this vault?'),
        content: const Text(
          'This deletes every record on this phone. Export a backup first if you need it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Destroy'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // Drop Drive session so a new vault can pick any Gmail on the phone.
      await GoogleDriveBackupService.signOut();
      await ref.read(sessionProvider.notifier).destroyVault();
    }
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    try {
      await ref.withLockHold(() async {
        final bytes = await ref.read(sessionProvider.notifier).exportBackup();
        if (!context.mounted) return;
        final choice = await showModalBottomSheet<String>(
          context: context,
          showDragHandle: true,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save_alt_outlined),
                title: const Text('Save to Files'),
                subtitle: const Text('Keep a copy on this phone or Drive'),
                onTap: () => Navigator.pop(context, 'save'),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share via WhatsApp, Email…'),
                subtitle: const Text('Opens the Android share sheet'),
                onTap: () => Navigator.pop(context, 'share'),
              ),
            ],
          ),
        );
        if (choice == null) return;
        if (choice == 'save') {
          final saved = await FilePicker.platform.saveFile(
            dialogTitle: 'Save $kAppName backup',
            fileName: 'amanaat-backup.amanahbak',
            bytes: bytes,
          );
          if (saved != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup saved.')),
            );
          }
          return;
        }
        final tmp = File(
          '${(await getTemporaryDirectory()).path}/amanaat-backup.amanahbak',
        );
        await tmp.writeAsBytes(bytes, flush: true);
        await Share.shareXFiles(
          [
            XFile(
              tmp.path,
              mimeType: 'application/octet-stream',
              name: 'amanaat-backup.amanahbak',
            ),
          ],
          subject: '$kAppName backup',
          text: '$kAppName encrypted backup. Keep this file private.',
        );
      });
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    if (!await confirmRestoreBackup(context)) return;
    try {
      await ref.withLockHold(() async {
        final picked = await FilePicker.platform.pickFiles(
          withData: true,
          type: FileType.any,
        );
        final bytes = picked?.files.single.bytes;
        if (bytes == null || !context.mounted) return;
        await applyBackupBytes(context, ref, bytes);
      });
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _GoogleDriveBackupSection extends ConsumerStatefulWidget {
  const _GoogleDriveBackupSection();

  @override
  ConsumerState<_GoogleDriveBackupSection> createState() =>
      _GoogleDriveBackupSectionState();
}

class _GoogleDriveBackupSectionState
    extends ConsumerState<_GoogleDriveBackupSection> {
  String? _account;
  bool _busy = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    try {
      final user = await GoogleDriveBackupService.currentUser();
      if (!mounted) return;
      setState(() => _account = user?.email ?? user?.displayName);
    } catch (_) {}
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _connect() async {
    setState(() {
      _busy = true;
      _status = 'Signing in…';
    });
    try {
      // Always show the phone's Google account list (not the last cached Gmail).
      final user =
          await GoogleDriveBackupService.signIn(forceAccountPicker: true);
      if (!mounted) return;
      setState(() => _account = user?.email ?? user?.displayName);
      _toast(user == null ? 'Sign-in cancelled' : 'Connected: $_account');
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = '';
        });
      }
    }
  }

  Future<void> _disconnect() async {
    await GoogleDriveBackupService.signOut();
    if (!mounted) return;
    setState(() => _account = null);
    _toast('Google Drive disconnected');
  }

  Future<void> _upload() async {
    setState(() {
      _busy = true;
      _status = 'Building backup…';
    });
    try {
      await ref.withLockHold(() async {
        final bytes =
            await ref.read(sessionProvider.notifier).exportBackup();
        await GoogleDriveBackupService.uploadBackup(
          bytes,
          onStatus: (s) {
            if (mounted) setState(() => _status = s);
          },
        );
      });
      _toast('Synced to Google Drive');
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = '';
        });
      }
    }
  }

  Future<void> _download() async {
    if (!await confirmRestoreBackup(context)) return;
    setState(() {
      _busy = true;
      _status = 'Downloading…';
    });
    try {
      await ref.withLockHold(() async {
        final bytes = await GoogleDriveBackupService.downloadBackup(
          onStatus: (s) {
            if (mounted) setState(() => _status = s);
          },
        );
        if (!mounted) return;
        await applyBackupBytes(context, ref, bytes);
      });
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = _account != null && _account!.isNotEmpty;
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud_outlined),
          title: Text(connected ? 'Connected: $_account' : 'Connect Google Drive'),
          subtitle: Text(
            connected
                ? 'Encrypted vault sync (same Google account as Budget)'
                : 'Sign in to upload / restore Amanaat backups',
          ),
          trailing: connected
              ? Wrap(
                  spacing: 4,
                  children: [
                    TextButton(
                      onPressed: _busy ? null : _connect,
                      child: const Text('Switch'),
                    ),
                    TextButton(
                      onPressed: _busy ? null : _disconnect,
                      child: const Text('Disconnect'),
                    ),
                  ],
                )
              : null,
          onTap: _busy ? null : (connected ? null : _connect),
        ),
        if (_busy)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_status.isEmpty ? 'Working…' : _status)),
              ],
            ),
          ),
        ListTile(
          enabled: !_busy,
          leading: const Icon(Icons.cloud_upload_outlined),
          title: const Text('Upload backup to Drive'),
          subtitle: const Text('Creates Amanaat_….amanahbak on your Drive'),
          onTap: _busy ? null : _upload,
        ),
        ListTile(
          enabled: !_busy,
          leading: const Icon(Icons.cloud_download_outlined),
          title: const Text('Restore from Drive'),
          subtitle: const Text('Latest Amanaat backup · replaces this vault'),
          onTap: _busy ? null : _download,
        ),
      ],
    );
  }
}
