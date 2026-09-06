import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/categories.dart';
import '../../core/share_record.dart';
import '../../data/database.dart';
import '../../state/lock_hold.dart';
import '../../state/session.dart';
import '../docs/scan_actions.dart';
import 'counter_pack_page.dart';
import 'record_detail_page.dart';
import 'record_editor_page.dart';

class RecordListPage extends ConsumerWidget {
  const RecordListPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final def = lookupCategory(categoryId, catalog);
    final items = (ref.watch(itemsProvider).valueOrNull ?? const [])
        .where((item) => item.categoryId == categoryId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(def.label),
        actions: [
          IconButton(
            tooltip: 'Camera',
            onPressed: () => captureAndAttachScan(
              context,
              ref,
              categoryId: categoryId,
            ),
            icon: const Icon(Icons.photo_camera_outlined),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'camera-$categoryId',
            tooltip: 'Camera',
            onPressed: () => captureAndAttachScan(
              context,
              ref,
              categoryId: categoryId,
            ),
            child: const Icon(Icons.photo_camera_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add-$categoryId',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RecordEditorPage(categoryId: categoryId),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Nothing in ${def.label} yet.\nTap + to add a record, or the camera to attach a photo.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  leading: Icon(def.icon, color: def.color),
                  title: Text(item.item.title),
                  subtitle: Text(_subtitle(item, def)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (supportsCounterPack(categoryId))
                        IconButton(
                          tooltip: 'Counter pack',
                          onPressed: () async {
                            await ref.withLockHold(() async {
                              if (!context.mounted) return;
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      CounterPackPage(itemId: item.item.id),
                                ),
                              );
                            });
                          },
                          icon: const Icon(Icons.badge_outlined),
                        ),
                      IconButton(
                        tooltip: 'Share',
                        onPressed: () =>
                            shareVaultRecord(context, ref, item: item),
                        icon: const Icon(Icons.share_outlined),
                      ),
                      if (item.item.favorite)
                        const Icon(Icons.star_rounded),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RecordDetailPage(itemId: item.item.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _subtitle(ItemWithFields item, CategoryDef def) {
    final username = item.fields.where((f) => f.key == 'username').firstOrNull;
    if (username != null && username.value.isNotEmpty) return username.value;
    final number = item.fields.where((f) => f.key == 'number').firstOrNull;
    if (number != null && number.value.isNotEmpty) return number.value;
    if (item.item.notes.isNotEmpty) return item.item.notes;
    return def.subtitle;
  }
}
