import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/categories.dart';
import '../../state/lock_hold.dart';
import '../../state/session.dart';

final scanBytesProvider =
    FutureProvider.family<Uint8List?, String>((ref, id) async {
  return ref.read(sessionProvider.notifier).loadScan(id);
});

Future<ImageSource?> pickScanSource(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: const Text('Take photo'),
          onTap: () => Navigator.pop(context, ImageSource.camera),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('Choose from gallery'),
          onTap: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ],
    ),
  );
}

Future<void> captureAndAttachScan(
  BuildContext context,
  WidgetRef ref, {
  String? categoryId,
}) async {
  final source = await pickScanSource(context);
  if (source == null || !context.mounted) return;
  await _captureAndSave(
    context,
    ref,
    source,
    itemId: null,
    categoryId: categoryId,
  );
}

Future<void> captureScanForItem(
  BuildContext context,
  WidgetRef ref,
  String itemId,
) async {
  final source = await pickScanSource(context);
  if (source == null || !context.mounted) return;
  await _captureAndSave(context, ref, source, itemId: itemId);
}

Future<Uint8List?> pickScanBytes(BuildContext context, WidgetRef ref) async {
  final source = await pickScanSource(context);
  if (source == null || !context.mounted) return null;
  return ref.withLockHold(() async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('The camera returned an empty image.');
    }
    return bytes;
  });
}

Future<void> _captureAndSave(
  BuildContext context,
  WidgetRef ref,
  ImageSource source, {
  required String? itemId,
  String? categoryId,
}) async {
  try {
    await ref.withLockHold(() async {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (picked == null) return;

      var targetId = itemId;
      targetId ??= await _createScanRecord(ref, categoryId: categoryId);
      await _savePicked(ref, targetId, picked);
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo saved in the vault.')),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save photo: $error')),
      );
    }
  }
}

Future<String> _createScanRecord(WidgetRef ref, {String? categoryId}) async {
  final db = ref.read(sessionProvider).db;
  if (db == null) {
    throw const FormatException('Unlock the vault first, then take the photo.');
  }
  final def = lookupCategory(
    categoryId ?? RecordCategory.identity.name,
    ref.read(catalogProvider),
  );
  return db.upsertItem(
    categoryId: categoryId ?? RecordCategory.identity.name,
    title: '${def.label} ${DateFormat('d MMM y, HH:mm').format(DateTime.now())}',
    notes: '',
    tags: 'scan',
    favorite: false,
    fields: const [],
  );
}

Future<void> _savePicked(WidgetRef ref, String itemId, XFile picked) async {
  final bytes = await picked.readAsBytes();
  if (bytes.isEmpty) {
    throw const FormatException('The camera returned an empty image.');
  }
  final label = 'Scan ${DateFormat('d MMM y, HH:mm').format(DateTime.now())}';
  await ref.read(sessionProvider.notifier).saveScan(
        itemId: itemId,
        label: label,
        bytes: bytes,
      );
  ref.invalidate(scanBytesProvider);
}
