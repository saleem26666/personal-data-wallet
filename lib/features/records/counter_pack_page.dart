import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/categories.dart';
import '../../data/database.dart';
import '../../state/session.dart';
import '../docs/scan_actions.dart';

class CounterPackPage extends ConsumerStatefulWidget {
  const CounterPackPage({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<CounterPackPage> createState() => _CounterPackPageState();
}

class _CounterPackPageState extends ConsumerState<CounterPackPage> {
  static const _seconds = 60;
  Timer? _timer;
  var _remaining = _seconds;
  var _page = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 1) {
        _timer?.cancel();
        Navigator.of(context).maybePop();
        return;
      }
      setState(() => _remaining -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  List<VaultField> _visibleFields(ItemWithFields item) {
    final preferred = [
      for (final field in item.fields)
        if (!field.concealed &&
            field.value.trim().isNotEmpty &&
            counterFieldKeys.contains(field.key))
          field,
    ];
    if (preferred.isNotEmpty) return preferred;
    return [
      for (final field in item.fields)
        if (!field.concealed && field.value.trim().isNotEmpty) field,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsProvider).valueOrNull ?? const [];
    final item = items.where((entry) => entry.item.id == widget.itemId).firstOrNull;
    if (item == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF1F5F9),
        body: Center(child: Text('Record not found')),
      );
    }
    final fields = _visibleFields(item);
    final attachments = item.attachments;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
                  ),
                  const Expanded(
                    child: Text(
                      'Counter pack',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      '${_remaining}s',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _remaining <= 10
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (attachments.isNotEmpty)
              Expanded(
                flex: 5,
                child: PageView.builder(
                  itemCount: attachments.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    final file = attachments[index];
                    final bytes = ref.watch(scanBytesProvider(file.id));
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: bytes.when(
                        data: (data) => data == null
                            ? const Center(child: Icon(Icons.broken_image_outlined))
                            : InteractiveViewer(
                                child: Image.memory(data, fit: BoxFit.contain),
                              ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, _) =>
                            const Center(child: Icon(Icons.lock_outline)),
                      ),
                    );
                  },
                ),
              )
            else
              const Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'No photo yet — add a scan from the record.',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
              ),
            if (attachments.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < attachments.length; i++)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page
                              ? const Color(0xFF0F766E)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              flex: 4,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(
                    item.item.title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final field in fields) ...[
                    Text(
                      field.label.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      field.value,
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontSize: field.key == 'number' || field.key == 'reg'
                            ? 28
                            : 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Closes automatically. Passwords and PINs stay hidden.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
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
