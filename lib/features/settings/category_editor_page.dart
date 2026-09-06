import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/categories.dart';
import '../../state/session.dart';
import 'category_actions.dart';

class CategoryEditorPage extends ConsumerStatefulWidget {
  const CategoryEditorPage({super.key, this.existing});

  final CategoryDef? existing;

  @override
  ConsumerState<CategoryEditorPage> createState() => _CategoryEditorPageState();
}

class _FieldDraft {
  _FieldDraft({required this.label, required this.kind});

  final TextEditingController label;
  FieldKind kind;
}

class _CategoryEditorPageState extends ConsumerState<CategoryEditorPage> {
  late final TextEditingController _name;
  late final TextEditingController _subtitle;
  late IconData _icon;
  late Color _color;
  late final List<_FieldDraft> _fields;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.label ?? '');
    _subtitle = TextEditingController(text: existing?.subtitle ?? '');
    _icon = existing?.icon ?? Icons.folder_rounded;
    _color = existing?.color ?? categoryColorChoices.first;
    if (existing != null && existing.fields.isNotEmpty) {
      _fields = [
        for (final field in existing.fields)
          _FieldDraft(
            label: TextEditingController(text: field.label),
            kind: field.kind,
          ),
      ];
    } else {
      _fields = [
        _FieldDraft(
          label: TextEditingController(text: 'Value'),
          kind: FieldKind.text,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _subtitle.dispose();
    for (final field in _fields) {
      field.label.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give this category a name.')),
      );
      return;
    }
    final fields = <FieldSpec>[
      for (final field in _fields)
        if (field.label.text.trim().isNotEmpty)
          FieldSpec(
            fieldKeyFromLabel(field.label.text),
            field.label.text.trim(),
            field.kind,
          ),
    ];
    if (fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one field.')),
      );
      return;
    }
    final db = ref.read(sessionProvider).db;
    if (db == null) return;
    await db.saveUserCategory(
      id: widget.existing?.id ?? 'user_${const Uuid().v4()}',
      label: name,
      subtitle: _subtitle.text.trim().isEmpty
          ? 'Your category'
          : _subtitle.text.trim(),
      iconCode: _icon.codePoint,
      colorValue: _color.toARGB32(),
      fieldsJson: encodeFields(fields),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Add category' : 'Edit category'),
        actions: [
          if (widget.existing != null)
            IconButton(
              tooltip: 'Delete',
              onPressed: () async {
                final deleted = await confirmAndDeleteCategory(
                  context,
                  ref,
                  widget.existing!,
                );
                if (deleted && context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Category name',
              hintText: 'e.g. Medical, Tax, Licenses',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitle,
            decoration: const InputDecoration(
              labelText: 'Short description',
              hintText: 'Optional',
            ),
          ),
          const SizedBox(height: 20),
          Text('Icon', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final icon in categoryIconChoices)
                InkWell(
                  onTap: () => setState(() => _icon = icon),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _icon.codePoint == icon.codePoint
                          ? _color.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: _icon.codePoint == icon.codePoint
                          ? Border.all(color: _color, width: 2)
                          : null,
                    ),
                    child: Icon(icon, color: _color),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Color', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              for (final color in categoryColorChoices)
                GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: color,
                    child: _color.toARGB32() == color.toARGB32()
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Fields', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'These boxes appear when you add a record in this category.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _fields.length; i++) ...[
            _fieldCard(i),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _fields.add(
                  _FieldDraft(
                    label: TextEditingController(),
                    kind: FieldKind.text,
                  ),
                );
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add field'),
          ),
        ],
      ),
    );
  }

  Widget _fieldCard(int index) {
    final field = _fields[index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: field.label,
                    decoration: InputDecoration(
                      labelText: 'Field ${index + 1} name',
                      hintText: 'e.g. Policy number',
                    ),
                  ),
                ),
                if (_fields.length > 1)
                  IconButton(
                    tooltip: 'Remove field',
                    onPressed: () {
                      setState(() {
                        _fields.removeAt(index).label.dispose();
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownMenu<FieldKind>(
              initialSelection: field.kind,
              label: const Text('Field type'),
              dropdownMenuEntries: [
                for (final kind in FieldKind.values)
                  DropdownMenuEntry(
                    value: kind,
                    label: fieldKindLabel(kind),
                  ),
              ],
              onSelected: (kind) {
                if (kind == null) return;
                setState(() => field.kind = kind);
              },
            ),
          ],
        ),
      ),
    );
  }
}
