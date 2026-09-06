import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import '../../core/categories.dart';
import '../../core/expiry.dart';
import '../../state/session.dart';
import '../../widgets/brand.dart';
import '../records/record_detail_page.dart';
import '../records/record_editor_page.dart';
import '../records/record_list_page.dart';
import '../search/search_page.dart';
import '../settings/category_actions.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider).valueOrNull ?? const [];
    final catalog = ref.watch(catalogProvider);
    final favorites = items.where((item) => item.item.favorite).toList();
    final expiring = expiringSoon(items);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AmanahMark(size: 32),
            SizedBox(width: 10),
            Text(kAppName),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Lock now',
            onPressed: () => ref.read(sessionProvider.notifier).lock(),
            icon: const Icon(Icons.lock_outline),
          ),
          IconButton(
            tooltip: 'Exit App',
            onPressed: SystemNavigator.pop,
            icon: const Icon(Icons.power_settings_new_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Material(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SearchPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.search, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(
                      'Search the vault',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expiring.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Needs attention', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final alert in expiring)
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.event_busy,
                    color: alert.daysLeft < 0
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                  title: Text(alert.item.item.title),
                  subtitle: Text(
                    alert.daysLeft < 0
                        ? '${alert.label} expired'
                        : '${alert.label} in ${alert.daysLeft} days',
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            RecordDetailPage(itemId: alert.item.item.id),
                      ),
                    );
                  },
                ),
              ),
          ],
          if (favorites.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Favorites',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  return ActionChip(
                    avatar: Icon(
                      lookupCategory(item.categoryId, catalog).icon,
                      size: 18,
                    ),
                    label: Text(item.item.title),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              RecordDetailPage(itemId: item.item.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Categories', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: catalog.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final category = catalog[index];
              final count = items
                  .where((item) => item.categoryId == category.id)
                  .length;
              return _CategoryTile(
                category: category,
                count: count,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RecordListPage(categoryId: category.id),
                    ),
                  );
                },
                onLongPress: () =>
                    confirmAndDeleteCategory(context, ref, category),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final catalog = ref.read(catalogProvider);
    final categoryId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'New record',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final category in catalog)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.color.withValues(alpha: 0.18),
                  child: Icon(category.icon, color: category.color),
                ),
                title: Text(category.label),
                subtitle: Text(category.subtitle),
                onTap: () => Navigator.pop(context, category.id),
              ),
          ],
        );
      },
    );
    if (categoryId == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecordEditorPage(categoryId: categoryId),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.count,
    required this.onTap,
    this.onLongPress,
  });

  final CategoryDef category;
  final int count;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: category.color.withValues(alpha: 0.16),
                child: Icon(category.icon, color: category.color),
              ),
              const Spacer(),
              Text(
                category.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                count == 0 ? category.subtitle : '$count saved',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
