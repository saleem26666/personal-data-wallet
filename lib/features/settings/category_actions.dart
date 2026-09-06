import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/categories.dart';
import '../../state/session.dart';

Future<bool> confirmAndDeleteCategory(
  BuildContext context,
  WidgetRef ref,
  CategoryDef category,
) async {
  final db = ref.read(sessionProvider).db;
  if (db == null) return false;

  final catalog = ref.read(catalogProvider);
  if (catalog.length <= 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Keep at least one category.')),
    );
    return false;
  }

  final count = await db.countItemsInCategory(category.id);
  if (!context.mounted) return false;

  final recordLabel = count == 1 ? '1 record' : '$count records';
  final content = count == 0
      ? (category.userDefined
          ? 'This category will be removed.'
          : 'It will be hidden from Home. You can restore it later in Settings.')
      : (category.userDefined
          ? '$recordLabel in ${category.label} will also be deleted. This cannot be undone.'
          : '$recordLabel in ${category.label} will also be deleted. The category can be restored later, empty.');

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete ${category.label}?'),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: count > 0
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          child: Text(count > 0 ? 'Delete $recordLabel' : 'Delete'),
        ),
      ],
    ),
  );
  if (ok != true) return false;

  await ref.read(sessionProvider.notifier).deleteCategory(category);
  if (!context.mounted) return true;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${category.label} deleted.')),
  );
  return true;
}
