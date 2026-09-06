import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/categories.dart';
import '../../core/crypto/password_generator.dart';
import '../../core/crypto/vault_crypto.dart';
import '../../data/database.dart';
import '../../state/session.dart';
import '../../widgets/brand.dart';
import '../docs/scan_actions.dart';

class RecordEditorPage extends ConsumerStatefulWidget {
  const RecordEditorPage({
    super.key,
    required this.categoryId,
    this.existing,
    this.viewOnly = false,
  });

  final String categoryId;
  final ItemWithFields? existing;
  final bool viewOnly;

  @override
  ConsumerState<RecordEditorPage> createState() => _RecordEditorPageState();
}

class _FieldDraft {
  _FieldDraft({
    required this.key,
    required this.label,
    required this.kind,
    required this.controller,
    required this.concealed,
  });

  final String key;
  final String label;
  FieldKind kind;
  final TextEditingController controller;
  bool concealed;
}

class _RecordEditorPageState extends ConsumerState<RecordEditorPage> {
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _tags;
  late bool _favorite;
  late final List<_FieldDraft> _fields;
  final _generator = PasswordGenerator();
  final List<Uint8List> _pendingPhotos = [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final def = lookupCategory(
      widget.categoryId,
      ref.read(catalogProvider),
    );
    _title = TextEditingController(text: existing?.item.title ?? '');
    _notes = TextEditingController(text: existing?.item.notes ?? '');
    _tags = TextEditingController(text: existing?.item.tags ?? '');
    _favorite = existing?.item.favorite ?? false;

    if (existing != null && existing.fields.isNotEmpty) {
      _fields = [
        for (final field in existing.fields)
          _FieldDraft(
            key: field.key,
            label: field.label,
            kind: FieldKind.values.firstWhere(
              (kind) => kind.name == field.fieldType,
              orElse: () => FieldKind.text,
            ),
            controller: TextEditingController(text: field.value),
            concealed: field.concealed,
          ),
      ];
    } else {
      _fields = [
        for (final spec in def.fields)
          _FieldDraft(
            key: spec.key,
            label: spec.label,
            kind: spec.kind,
            controller: TextEditingController(),
            concealed: spec.kind == FieldKind.password || spec.kind == FieldKind.pin,
          ),
      ];
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _tags.dispose();
    for (final field in _fields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final db = ref.read(sessionProvider).db;
    if (db == null) return;
    final itemId = await db.upsertItem(
      id: widget.existing?.item.id,
      categoryId: widget.categoryId,
      title: _title.text,
      notes: _notes.text,
      tags: _tags.text,
      favorite: _favorite,
      fields: [
        for (final field in _fields)
          VaultFieldsCompanion.insert(
            id: '',
            itemId: '',
            key: field.key,
            label: field.label,
            value: field.controller.text,
            fieldType: field.kind.name,
            sortOrder: 0,
            concealed: Value(field.concealed),
          ),
      ],
    );
    for (final bytes in _pendingPhotos) {
      await ref.read(sessionProvider.notifier).saveScan(
            itemId: itemId,
            label: 'Scan ${DateFormat('d MMM y, HH:mm').format(DateTime.now())}',
            bytes: bytes,
          );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _addPhoto() async {
    if (widget.viewOnly) return;
    final existingId = widget.existing?.item.id;
    if (existingId != null) {
      await captureScanForItem(context, ref, existingId);
      return;
    }
    try {
      final bytes = await pickScanBytes(context, ref);
      if (bytes == null || !mounted) return;
      setState(() => _pendingPhotos.add(bytes));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add photo: $error')),
      );
    }
  }

  Future<void> _pickDate(_FieldDraft field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(field.controller.text) ?? now,
      firstDate: DateTime(now.year - 40),
      lastDate: DateTime(now.year + 40),
    );
    if (picked != null) {
      field.controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final def = lookupCategory(
      widget.categoryId,
      ref.watch(catalogProvider),
    );
    final readOnly = widget.viewOnly;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New ${def.label}' : 'Edit'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _favorite = !_favorite),
            icon: Icon(_favorite ? Icons.star_rounded : Icons.star_outline),
          ),
          if (!readOnly)
            IconButton(
              tooltip: 'Add photo',
              onPressed: _addPhoto,
              icon: const Icon(Icons.photo_camera_outlined),
            ),
          if (!readOnly)
            TextButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _title,
            readOnly: readOnly,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          for (final field in _fields) ...[
            _buildField(field, readOnly),
            const SizedBox(height: 12),
          ],
          if (!readOnly)
            TextButton.icon(
              onPressed: () async {
                final label = await _askLabel();
                if (label == null || label.trim().isEmpty) return;
                setState(() {
                  _fields.add(
                    _FieldDraft(
                      key: label.toLowerCase().replaceAll(' ', '_'),
                      label: label.trim(),
                      kind: FieldKind.text,
                      controller: TextEditingController(),
                      concealed: false,
                    ),
                  );
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add field'),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _notes,
            readOnly: readOnly,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tags,
            readOnly: readOnly,
            decoration: const InputDecoration(
              labelText: 'Tags',
              hintText: 'work, personal',
            ),
          ),
          const SizedBox(height: 20),
          Text('Photos', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (widget.existing != null && widget.existing!.attachments.isNotEmpty)
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.existing!.attachments.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final file = widget.existing!.attachments[index];
                  final bytes = ref.watch(scanBytesProvider(file.id));
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: bytes.when(
                        data: (data) => data == null
                            ? const ColoredBox(
                                color: Color(0x11000000),
                                child: Icon(Icons.broken_image_outlined),
                              )
                            : Image.memory(data, fit: BoxFit.cover),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, _) => const Icon(Icons.lock_outline),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_pendingPhotos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pendingPhotos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _pendingPhotos[index],
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
          if (!readOnly)
            TextButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Add photo'),
            ),
        ],
      ),
    );
  }

  Widget _buildField(_FieldDraft field, bool readOnly) {
    final isSecret = field.kind == FieldKind.password || field.kind == FieldKind.pin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: field.controller,
                readOnly: readOnly || field.kind == FieldKind.date,
                obscureText: isSecret && field.concealed,
                minLines: field.kind == FieldKind.multiline ? 3 : 1,
                maxLines: field.kind == FieldKind.multiline ? 6 : 1,
                keyboardType: switch (field.kind) {
                  FieldKind.email => TextInputType.emailAddress,
                  FieldKind.url => TextInputType.url,
                  FieldKind.number || FieldKind.pin => TextInputType.number,
                  FieldKind.multiline => TextInputType.multiline,
                  _ => TextInputType.text,
                },
                onTap: field.kind == FieldKind.date && !readOnly
                    ? () => _pickDate(field)
                    : null,
                decoration: InputDecoration(
                  labelText: field.label,
                  suffixIcon: isSecret
                      ? IconButton(
                          onPressed: () =>
                              setState(() => field.concealed = !field.concealed),
                          icon: Icon(
                            field.concealed
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        )
                      : null,
                ),
                onChanged: field.kind == FieldKind.password
                    ? (_) => setState(() {})
                    : null,
              ),
            ),
            if (field.kind == FieldKind.password && !readOnly)
              IconButton(
                tooltip: 'Generate',
                onPressed: () {
                  field.controller.text =
                      _generator.generate(const GeneratorOptions());
                  setState(() {});
                },
                icon: const Icon(Icons.auto_awesome),
              ),
          ],
        ),
        if (field.kind == FieldKind.password && field.controller.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          PasswordStrengthBar(
            score: VaultCrypto.passwordScore(field.controller.text),
          ),
        ],
      ],
    );
  }

  Future<String?> _askLabel() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Field name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Recovery email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
