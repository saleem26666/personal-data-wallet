import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/crypto/vault_crypto.dart';
import 'tables.dart';

part 'database.g.dart';

class ItemWithFields {
  const ItemWithFields(this.item, this.fields, [this.attachments = const []]);

  final VaultItem item;
  final List<VaultField> fields;
  final List<VaultAttachment> attachments;

  String get categoryId => item.categoryId;

  String searchBlob() {
    final parts = <String>[
      item.title,
      item.notes,
      item.tags,
      ...fields.map((f) => '${f.label} ${f.value}'),
    ];
    return parts.join(' ').toLowerCase();
  }
}

@DriftDatabase(
  tables: [
    VaultItems,
    VaultFields,
    VaultAttachments,
    UserCategories,
    HiddenCategories,
  ],
)
class VaultDatabase extends _$VaultDatabase {
  VaultDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(vaultAttachments);
          }
          if (from < 3) {
            await m.createTable(userCategories);
          }
          if (from < 4) {
            await m.createTable(hiddenCategories);
          }
        },
      );

  static Future<File> dbFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'amanah', 'amanah.sqlite'));
  }

  static Future<VaultDatabase> open(Uint8List vaultKey) async {
    return openAt(await dbFile(), vaultKey);
  }

  static Future<VaultDatabase> openAt(File file, Uint8List vaultKey) async {
    await file.parent.create(recursive: true);
    final passphrase = escapeSqlLiteral(vaultKeyToPragma(vaultKey));
    return VaultDatabase(
      LazyDatabase(() async {
        return NativeDatabase.createInBackground(
          file,
          setup: (rawDb) {
            final cipher = rawDb.select('PRAGMA cipher;');
            if (cipher.isEmpty) {
              throw StateError(
                'Encrypted SQLite is not linked. Check sqlite3mc hooks.',
              );
            }
            rawDb.execute("PRAGMA key = '$passphrase';");
            rawDb.execute('PRAGMA foreign_keys = ON;');
          },
        );
      }),
    );
  }

  Stream<List<ItemWithFields>> watchAll() {
    return (select(vaultItems)..orderBy([
          (t) => OrderingTerm.desc(t.favorite),
          (t) => OrderingTerm.desc(t.updatedAt),
        ]))
        .watch()
        .asyncMap((items) async {
          if (items.isEmpty) return <ItemWithFields>[];
          final fields = await (select(vaultFields)
                ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
              .get();
          final attachments = await (select(vaultAttachments)
                ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
              .get();
          final byItem = <String, List<VaultField>>{};
          final filesByItem = <String, List<VaultAttachment>>{};
          for (final field in fields) {
            byItem.putIfAbsent(field.itemId, () => []).add(field);
          }
          for (final file in attachments) {
            filesByItem.putIfAbsent(file.itemId, () => []).add(file);
          }
          return [
            for (final item in items)
              ItemWithFields(
                item,
                byItem[item.id] ?? const [],
                filesByItem[item.id] ?? const [],
              ),
          ];
        });
  }

  Future<ItemWithFields?> getItem(String id) async {
    final item = await (select(vaultItems)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (item == null) return null;
    final fields = await (select(vaultFields)
          ..where((t) => t.itemId.equals(id))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    final attachments = await (select(vaultAttachments)
          ..where((t) => t.itemId.equals(id))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return ItemWithFields(item, fields, attachments);
  }

  Future<String> upsertItem({
    String? id,
    required String categoryId,
    required String title,
    required String notes,
    required String tags,
    required bool favorite,
    required List<VaultFieldsCompanion> fields,
  }) async {
    final now = DateTime.now();
    final itemId = id ?? const Uuid().v4();
    final resolvedTitle = title.trim().isEmpty ? 'Untitled' : title.trim();
    await transaction(() async {
      final existing = id == null
          ? null
          : await (select(vaultItems)..where((t) => t.id.equals(itemId)))
              .getSingleOrNull();
      if (existing == null) {
        await into(vaultItems).insert(
          VaultItemsCompanion.insert(
            id: itemId,
            categoryId: categoryId,
            title: resolvedTitle,
            notes: Value(notes),
            tags: Value(tags),
            favorite: Value(favorite),
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        await (update(vaultItems)..where((t) => t.id.equals(itemId))).write(
          VaultItemsCompanion(
            categoryId: Value(categoryId),
            title: Value(resolvedTitle),
            notes: Value(notes),
            tags: Value(tags),
            favorite: Value(favorite),
            updatedAt: Value(now),
          ),
        );
        await (delete(vaultFields)..where((t) => t.itemId.equals(itemId))).go();
      }
      for (var i = 0; i < fields.length; i++) {
        await into(vaultFields).insert(
          fields[i].copyWith(
            id: Value(const Uuid().v4()),
            itemId: Value(itemId),
            sortOrder: Value(i),
          ),
        );
      }
    });
    return itemId;
  }

  Future<void> deleteItem(String id) async {
    await transaction(() async {
      await (delete(vaultAttachments)..where((t) => t.itemId.equals(id))).go();
      await (delete(vaultFields)..where((t) => t.itemId.equals(id))).go();
      await (delete(vaultItems)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<VaultAttachment> addAttachment({
    required String itemId,
    required String label,
    String? id,
    DateTime? createdAt,
  }) async {
    final row = VaultAttachmentsCompanion.insert(
      id: id ?? const Uuid().v4(),
      itemId: itemId,
      label: label,
      createdAt: createdAt ?? DateTime.now(),
    );
    await into(vaultAttachments).insert(row);
    return VaultAttachment(
      id: row.id.value,
      itemId: itemId,
      label: label,
      createdAt: row.createdAt.value,
    );
  }

  Future<List<UserCategory>> allUserCategories() {
    return (select(userCategories)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  Future<void> deleteAttachment(String id) {
    return (delete(vaultAttachments)..where((t) => t.id.equals(id))).go();
  }

  Future<void> setFavorite(String id, bool favorite) {
    return (update(vaultItems)..where((t) => t.id.equals(id))).write(
      VaultItemsCompanion(
        favorite: Value(favorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> touch(String id) {
    return (update(vaultItems)..where((t) => t.id.equals(id))).write(
      VaultItemsCompanion(lastUsedAt: Value(DateTime.now())),
    );
  }

  Stream<List<UserCategory>> watchUserCategories() {
    return (select(userCategories)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch();
  }

  Future<void> saveUserCategory({
    required String id,
    required String label,
    required String subtitle,
    required int iconCode,
    required int colorValue,
    required String fieldsJson,
  }) async {
    final existing = await (select(userCategories)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      await into(userCategories).insert(
        UserCategoriesCompanion.insert(
          id: id,
          label: label,
          subtitle: Value(subtitle),
          iconCode: iconCode,
          colorValue: colorValue,
          fieldsJson: fieldsJson,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      await (update(userCategories)..where((t) => t.id.equals(id))).write(
        UserCategoriesCompanion(
          label: Value(label),
          subtitle: Value(subtitle),
          iconCode: Value(iconCode),
          colorValue: Value(colorValue),
          fieldsJson: Value(fieldsJson),
        ),
      );
    }
  }

  Future<int> countItemsInCategory(String id) async {
    final count = countAll();
    final query = selectOnly(vaultItems)
      ..addColumns([count])
      ..where(vaultItems.categoryId.equals(id));
    return await query.map((row) => row.read(count) ?? 0).getSingle();
  }

  Future<List<String>> attachmentIdsInCategory(String id) async {
    final items = await (select(vaultItems)..where((t) => t.categoryId.equals(id)))
        .get();
    if (items.isEmpty) return const [];
    final itemIds = [for (final item in items) item.id];
    final files = await (select(vaultAttachments)
          ..where((t) => t.itemId.isIn(itemIds)))
        .get();
    return [for (final file in files) file.id];
  }

  Stream<Set<String>> watchHiddenCategoryIds() {
    return select(hiddenCategories).watch().map(
          (rows) => {for (final row in rows) row.id},
        );
  }

  Future<void> restoreHiddenCategory(String id) {
    return (delete(hiddenCategories)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteUserCategory(String id) =>
      deleteCategory(id: id, userDefined: true);

  Future<void> deleteCategory({
    required String id,
    required bool userDefined,
  }) async {
    await transaction(() async {
      final items = await (select(vaultItems)..where((t) => t.categoryId.equals(id)))
          .get();
      final itemIds = [for (final item in items) item.id];
      if (itemIds.isNotEmpty) {
        await (delete(vaultAttachments)..where((t) => t.itemId.isIn(itemIds))).go();
        await (delete(vaultFields)..where((t) => t.itemId.isIn(itemIds))).go();
        await (delete(vaultItems)..where((t) => t.categoryId.equals(id))).go();
      }
      if (userDefined) {
        await (delete(userCategories)..where((t) => t.id.equals(id))).go();
      } else {
        await into(hiddenCategories).insert(
          HiddenCategoriesCompanion.insert(id: id),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }
}
