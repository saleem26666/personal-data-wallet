import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/categories.dart';
import '../../core/share_record.dart';
import '../../state/session.dart';
import '../records/record_detail_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsProvider).valueOrNull ?? const [];
    final catalog = ref.watch(catalogProvider);
    final needle = _query.trim().toLowerCase();
    final results = needle.isEmpty
        ? items.take(20).toList()
        : items.where((item) => item.searchBlob().contains(needle)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Title, username, notes, tags…',
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      needle.isEmpty
                          ? 'Your recent records will appear here.'
                          : 'No matches for “$_query”.',
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      final def = lookupCategory(item.categoryId, catalog);
                      return ListTile(
                        leading: Icon(def.icon, color: def.color),
                        title: Text(item.item.title),
                        subtitle: Text(def.label),
                        trailing: IconButton(
                          tooltip: 'Share',
                          onPressed: () =>
                              shareVaultRecord(context, ref, item: item),
                          icon: const Icon(Icons.share_outlined),
                        ),
                        onTap: () {
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
      ),
    );
  }
}
