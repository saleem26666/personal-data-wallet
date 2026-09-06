import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/session.dart';

Future<bool> confirmRestoreBackup(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore backup?'),
          content: const Text(
            'This replaces the vault currently on this phone. After restore, unlock with the backup master password.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        ),
      ) ??
      false;
}

Future<void> applyBackupBytes(
  BuildContext context,
  WidgetRef ref,
  Uint8List bytes,
) async {
  await ref.read(sessionProvider.notifier).importBackup(bytes);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup restored. Unlock with your password.'),
      ),
    );
  }
}
