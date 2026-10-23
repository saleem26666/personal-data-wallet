import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/categories.dart';
import '../../core/share_record.dart';
import '../../data/database.dart';
import '../../state/lock_hold.dart';
import '../../state/session.dart';
import '../docs/scan_actions.dart';
import 'counter_pack_page.dart';
import 'record_editor_page.dart';

class RecordDetailPage extends ConsumerWidget {
  const RecordDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider).valueOrNull ?? const [];
    final item = items.where((entry) => entry.item.id == itemId).firstOrNull;
    if (item == null) {
      return const Scaffold(body: Center(child: Text('Record not found')));
    }
    final catalog = ref.watch(catalogProvider);
    final def = lookupCategory(item.categoryId, catalog);
    final clipboard = ref.read(clipboardProvider);
    final db = ref.read(sessionProvider).db;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.item.title),
        actions: [
          IconButton(
            tooltip: item.item.favorite ? 'Unfavorite' : 'Favorite',
            onPressed: () => db?.setFavorite(item.item.id, !item.item.favorite),
            icon: Icon(
              item.item.favorite ? Icons.star_rounded : Icons.star_outline,
            ),
          ),
          IconButton(
            tooltip: 'Scan document',
            onPressed: () => captureScanForItem(context, ref, item.item.id),
            icon: const Icon(Icons.photo_camera_outlined),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: () => shareVaultRecord(context, ref, item: item),
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RecordEditorPage(
                    categoryId: item.categoryId,
                    existing: item,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'counter') {
                await ref.withLockHold(() async {
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CounterPackPage(itemId: item.item.id),
                    ),
                  );
                });
                return;
              }
              if (value == 'share') {
                await shareVaultRecord(context, ref, item: item);
                return;
              }
              if (value == 'delete') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete record?'),
                    content: const Text('This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(sessionProvider.notifier).deleteRecord(
                        item.item.id,
                        attachmentIds: [
                          for (final file in item.attachments) file.id,
                        ],
                      );
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (context) => [
              if (supportsCounterPack(item.categoryId))
                const PopupMenuItem(
                  value: 'counter',
                  child: Text('Show at counter'),
                ),
              const PopupMenuItem(value: 'share', child: Text('Share')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: def.color.withValues(alpha: 0.16),
                child: Icon(def.icon, color: def.color),
              ),
              const SizedBox(width: 12),
              Text(def.label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 20),
          if (supportsCounterPack(item.categoryId)) ...[
            FilledButton.icon(
              onPressed: () async {
                await ref.withLockHold(() async {
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CounterPackPage(itemId: item.item.id),
                    ),
                  );
                });
              },
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Show at counter'),
            ),
            const SizedBox(height: 8),
            Text(
              'Large photo and ID fields only. Auto-closes in 60 seconds. PINs stay hidden.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
          ],
          for (final field in item.fields)
            if (field.value.trim().isNotEmpty)
              _FieldTile(
                field: field,
                onCopy: () async {
                  await clipboard.copy(field.value);
                  await db?.touch(item.item.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied · clipboard clears in 30 seconds'),
                      ),
                    );
                  }
                },
                onOpen: _isOpenableUrlField(field)
                    ? () => _openUrl(context, field.value)
                    : null,
              ),
          if (item.attachments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Documents', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item.attachments.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final file = item.attachments[index];
                  return _AttachmentThumb(
                    id: file.id,
                    label: file.label,
                    onShare: () => shareScanImage(
                      context,
                      ref,
                      attachmentId: file.id,
                      label: file.label,
                    ),
                    onDelete: () => ref
                        .read(sessionProvider.notifier)
                        .removeScan(file.id),
                  );
                },
              ),
            ),
          ],
          if (item.item.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Notes', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(item.item.notes),
          ],
        ],
      ),
    );
  }

  /// Website / URL fields — Logins "website" key or any url-type field.
  static bool _isOpenableUrlField(VaultField field) {
    if (field.value.trim().isEmpty) return false;
    if (field.fieldType == FieldKind.url.name) return true;
    final key = field.key.toLowerCase();
    if (key == 'website' || key == 'url' || key == 'link') return true;
    final label = field.label.toLowerCase();
    if (label.contains('website') || label == 'url') return true;
    return false;
  }

  static Future<void> _openUrl(BuildContext context, String raw) async {
    var value = raw.trim();
    if (value.isEmpty) return;
    // Strip accidental spaces / wrap plain domains.
    if (!value.contains('://')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid website: $raw')),
        );
      }
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open website')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open failed: $e')),
        );
      }
    }
  }
}

class _FieldTile extends StatefulWidget {
  const _FieldTile({
    required this.field,
    required this.onCopy,
    this.onOpen,
  });

  final VaultField field;
  final VoidCallback onCopy;
  final VoidCallback? onOpen;

  @override
  State<_FieldTile> createState() => _FieldTileState();
}

class _FieldTileState extends State<_FieldTile> {
  late bool _hidden = widget.field.concealed;

  @override
  Widget build(BuildContext context) {
    final value = _hidden ? '••••••••' : widget.field.value;
    final isLink = widget.onOpen != null && !_hidden;
    return Card(
      child: ListTile(
        onTap: widget.onOpen,
        title: Text(widget.field.label),
        subtitle: Text(
          value,
          style: TextStyle(
            letterSpacing: 0.3,
            color: isLink ? Theme.of(context).colorScheme.primary : null,
            decoration: isLink ? TextDecoration.underline : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.field.concealed)
              IconButton(
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                  _hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            if (widget.onOpen != null)
              IconButton(
                tooltip: 'Open website',
                onPressed: widget.onOpen,
                icon: const Icon(Icons.open_in_browser_rounded),
              ),
            IconButton(
              onPressed: widget.onCopy,
              icon: const Icon(Icons.copy_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentThumb extends ConsumerWidget {
  const _AttachmentThumb({
    required this.id,
    required this.label,
    required this.onShare,
    required this.onDelete,
  });

  final String id;
  final String label;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(scanBytesProvider(id));
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          Expanded(
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  final data = bytes.valueOrNull;
                  if (data == null) return;
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          title: Text(label),
                          actions: [
                            IconButton(
                              tooltip: 'Share',
                              onPressed: onShare,
                              icon: const Icon(Icons.share_outlined),
                            ),
                          ],
                        ),
                        body: Center(child: InteractiveViewer(child: Image.memory(data))),
                      ),
                    ),
                  );
                },
                onLongPress: onDelete,
                child: bytes.when(
                  data: (data) => data == null
                      ? const Icon(Icons.broken_image_outlined)
                      : Image.memory(data, fit: BoxFit.cover, width: 120),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Icon(Icons.lock_outline),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: onShare,
                child: const Icon(Icons.share_outlined, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
