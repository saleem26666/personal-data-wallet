import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/share_record.dart';
import '../../data/database.dart';
import '../../state/session.dart';
import '../records/record_detail_page.dart';
import 'scan_actions.dart';

class DocsPage extends ConsumerWidget {
  const DocsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider).valueOrNull ?? const [];
    final scans = [
      for (final item in items)
        for (final file in item.attachments) (item: item, file: file),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'scan-camera',
        onPressed: () => captureAndAttachScan(context, ref),
        icon: const Icon(Icons.photo_camera_outlined),
        label: const Text('Camera'),
      ),
      body: scans.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera is here',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Photograph a CNIC, passport, card, or any document. The image is encrypted in this app — it is not saved to your gallery.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: scans.length,
              itemBuilder: (context, index) {
                final scan = scans[index];
                return _ScanTile(
                  item: scan.item,
                  file: scan.file,
                  onOpen: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            RecordDetailPage(itemId: scan.item.item.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _ScanTile extends ConsumerWidget {
  const _ScanTile({
    required this.item,
    required this.file,
    required this.onOpen,
  });

  final ItemWithFields item;
  final VaultAttachment file;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(scanBytesProvider(file.id));
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: bytes.when(
                data: (data) => data == null
                    ? const Center(child: Icon(Icons.broken_image_outlined))
                    : Image.memory(data, fit: BoxFit.cover),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Center(child: Icon(Icons.lock_outline)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      file.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Share',
                    onPressed: () => shareScanImage(
                      context,
                      ref,
                      attachmentId: file.id,
                      label: file.label,
                    ),
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
