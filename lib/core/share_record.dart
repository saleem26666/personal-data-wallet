import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'app_info.dart';
import 'categories.dart';
import '../data/database.dart';
import '../state/lock_hold.dart';
import '../state/session.dart';

String formatRecordShare(ItemWithFields item, CategoryDef category) {
  final lines = <String>[
    '$kAppName — ${category.label}',
    item.item.title,
    '',
    for (final field in item.fields)
      if (field.value.trim().isNotEmpty) '${field.label}: ${field.value}',
  ];
  if (item.item.notes.trim().isNotEmpty) {
    lines.addAll(['', 'Notes', item.item.notes.trim()]);
  }
  return lines.join('\n').trim();
}

String _imageName(String label, Uint8List bytes) {
  final slug = label.trim().isEmpty
      ? 'document'
      : label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final ext = bytes.length >= 8 && bytes[0] == 0x89 && bytes[1] == 0x50
      ? 'png'
      : 'jpg';
  final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
  return '${slug.isEmpty ? 'document' : slug}.$ext|$mime';
}

Future<bool> _confirmShare(BuildContext context, {required bool hasSecrets}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Share this data?'),
          content: Text(
            hasSecrets
                ? 'Passwords and other fields will be sent as readable text through WhatsApp or any app you pick.'
                : 'This will open the Android share sheet so you can send it on WhatsApp, email, or Files.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Share'),
            ),
          ],
        ),
      ) ??
      false;
}

Future<void> shareVaultRecord(
  BuildContext context,
  WidgetRef ref, {
  required ItemWithFields item,
}) async {
  final catalog = ref.read(catalogProvider);
  final category = lookupCategory(item.categoryId, catalog);
  final hasSecrets = item.fields.any(
    (field) => field.concealed && field.value.trim().isNotEmpty,
  );
  final ok = await _confirmShare(context, hasSecrets: hasSecrets);
  if (!ok || !context.mounted) return;

  try {
    await ref.withLockHold(() async {
      final text = formatRecordShare(item, category);
      if (text.isEmpty && item.attachments.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nothing to share in this record.')),
          );
        }
        return;
      }
      final files = <XFile>[];
      final tmp = await getTemporaryDirectory();
      for (final attachment in item.attachments) {
        final bytes = await ref.read(sessionProvider.notifier).loadScan(attachment.id);
        final meta = _imageName(attachment.label, bytes);
        final parts = meta.split('|');
        final file = File('${tmp.path}/share-${attachment.id}-${parts[0]}');
        await file.writeAsBytes(bytes, flush: true);
        files.add(XFile(file.path, mimeType: parts[1], name: parts[0]));
      }
      if (files.isEmpty) {
        await Share.share(text, subject: '${item.item.title} · $kAppName');
      } else {
        await Share.shareXFiles(
          files,
          text: text.isEmpty ? null : text,
          subject: '${item.item.title} · $kAppName',
        );
      }
    });
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

Future<void> shareScanImage(
  BuildContext context,
  WidgetRef ref, {
  required String attachmentId,
  required String label,
}) async {
  final ok = await _confirmShare(context, hasSecrets: false);
  if (!ok || !context.mounted) return;
  try {
    await ref.withLockHold(() async {
      final bytes = await ref.read(sessionProvider.notifier).loadScan(attachmentId);
      final meta = _imageName(label, bytes);
      final parts = meta.split('|');
      final tmp = await getTemporaryDirectory();
      final file = File('${tmp.path}/share-$attachmentId-${parts[0]}');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: parts[1], name: parts[0])],
        subject: '$label · $kAppName',
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
