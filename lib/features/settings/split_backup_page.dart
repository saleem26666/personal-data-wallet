import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_info.dart';
import '../../state/lock_hold.dart';
import '../../state/session.dart';

class SplitBackupPage extends ConsumerStatefulWidget {
  const SplitBackupPage({super.key});

  @override
  ConsumerState<SplitBackupPage> createState() => _SplitBackupPageState();
}

class _SplitBackupPageState extends ConsumerState<SplitBackupPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _selected = <String>{'identity', 'bank'};
  var _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final items = ref.watch(itemsProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Family split backup')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Export only the categories you pick into a separate encrypted file. '
            'They restore it with the share password — not your master password.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text('Categories', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final category in catalog)
            Builder(
              builder: (context) {
                final count =
                    items.where((item) => item.categoryId == category.id).length;
                return CheckboxListTile(
                  value: _selected.contains(category.id),
                  onChanged: count == 0
                      ? null
                      : (value) {
                          setState(() {
                            if (value == true) {
                              _selected.add(category.id);
                            } else {
                              _selected.remove(category.id);
                            }
                          });
                        },
                  secondary: CircleAvatar(
                    backgroundColor: category.color.withValues(alpha: 0.18),
                    child: Icon(category.icon, color: category.color),
                  ),
                  title: Text(category.label),
                  subtitle: Text(count == 0 ? 'Empty' : '$count saved'),
                );
              },
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Share password',
              helperText: 'At least 8 characters — give this to the recipient',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm share password',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _busy ? null : () => _export(context),
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.group_outlined),
            label: Text(_busy ? 'Building…' : 'Create split backup'),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    if (_password.text.length < 8 || _password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Share passwords must match and be 8+ characters.'),
        ),
      );
      return;
    }
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one category.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await ref.withLockHold(() async {
        final bytes = await ref.read(sessionProvider.notifier).exportSplitBackup(
              categoryIds: Set<String>.from(_selected),
              sharePassword: _password.text,
            );
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
                onTap: () => Navigator.pop(context, 'save'),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share via WhatsApp, Email…'),
                onTap: () => Navigator.pop(context, 'share'),
              ),
            ],
          ),
        );
        if (choice == null) return;
        final name = 'amanaat-family.amanahbak';
        if (choice == 'save') {
          final saved = await FilePicker.platform.saveFile(
            dialogTitle: 'Save $kAppName family backup',
            fileName: name,
            bytes: bytes,
          );
          if (saved != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Family backup saved.')),
            );
          }
          return;
        }
        final tmp = File('${(await getTemporaryDirectory()).path}/$name');
        await tmp.writeAsBytes(bytes, flush: true);
        await Share.shareXFiles(
          [
            XFile(
              tmp.path,
              mimeType: 'application/octet-stream',
              name: name,
            ),
          ],
          subject: '$kAppName family backup',
          text:
              '$kAppName family split backup. Unlock with the share password, not the original master password.',
        );
      });
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
