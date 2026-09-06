// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VaultItemsTable extends VaultItems
    with TableInfo<$VaultItemsTable, VaultItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    title,
    favorite,
    lastUsedAt,
    createdAt,
    updatedAt,
    notes,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaultItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
    );
  }

  @override
  $VaultItemsTable createAlias(String alias) {
    return $VaultItemsTable(attachedDatabase, alias);
  }
}

class VaultItem extends DataClass implements Insertable<VaultItem> {
  final String id;
  final String categoryId;
  final String title;
  final bool favorite;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes;
  final String tags;
  const VaultItem({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.favorite,
    this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.notes,
    required this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['title'] = Variable<String>(title);
    map['favorite'] = Variable<bool>(favorite);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['notes'] = Variable<String>(notes);
    map['tags'] = Variable<String>(tags);
    return map;
  }

  VaultItemsCompanion toCompanion(bool nullToAbsent) {
    return VaultItemsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      title: Value(title),
      favorite: Value(favorite),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      notes: Value(notes),
      tags: Value(tags),
    );
  }

  factory VaultItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultItem(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      title: serializer.fromJson<String>(json['title']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      notes: serializer.fromJson<String>(json['notes']),
      tags: serializer.fromJson<String>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'title': serializer.toJson<String>(title),
      'favorite': serializer.toJson<bool>(favorite),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'notes': serializer.toJson<String>(notes),
      'tags': serializer.toJson<String>(tags),
    };
  }

  VaultItem copyWith({
    String? id,
    String? categoryId,
    String? title,
    bool? favorite,
    Value<DateTime?> lastUsedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? tags,
  }) => VaultItem(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    title: title ?? this.title,
    favorite: favorite ?? this.favorite,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
  );
  VaultItem copyWithCompanion(VaultItemsCompanion data) {
    return VaultItem(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      title: data.title.present ? data.title.value : this.title,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultItem(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('favorite: $favorite, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    title,
    favorite,
    lastUsedAt,
    createdAt,
    updatedAt,
    notes,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultItem &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.title == this.title &&
          other.favorite == this.favorite &&
          other.lastUsedAt == this.lastUsedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.notes == this.notes &&
          other.tags == this.tags);
}

class VaultItemsCompanion extends UpdateCompanion<VaultItem> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> title;
  final Value<bool> favorite;
  final Value<DateTime?> lastUsedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> notes;
  final Value<String> tags;
  final Value<int> rowid;
  const VaultItemsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.favorite = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultItemsCompanion.insert({
    required String id,
    required String categoryId,
    required String title,
    this.favorite = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VaultItem> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? title,
    Expression<bool>? favorite,
    Expression<DateTime>? lastUsedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (title != null) 'title': title,
      if (favorite != null) 'favorite': favorite,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<String>? title,
    Value<bool>? favorite,
    Value<DateTime?>? lastUsedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? notes,
    Value<String>? tags,
    Value<int>? rowid,
  }) {
    return VaultItemsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      favorite: favorite ?? this.favorite,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultItemsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('favorite: $favorite, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaultFieldsTable extends VaultFields
    with TableInfo<$VaultFieldsTable, VaultField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldTypeMeta = const VerificationMeta(
    'fieldType',
  );
  @override
  late final GeneratedColumn<String> fieldType = GeneratedColumn<String>(
    'field_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _concealedMeta = const VerificationMeta(
    'concealed',
  );
  @override
  late final GeneratedColumn<bool> concealed = GeneratedColumn<bool>(
    'concealed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("concealed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    key,
    label,
    value,
    fieldType,
    sortOrder,
    concealed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_fields';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultField> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('field_type')) {
      context.handle(
        _fieldTypeMeta,
        fieldType.isAcceptableOrUnknown(data['field_type']!, _fieldTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldTypeMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('concealed')) {
      context.handle(
        _concealedMeta,
        concealed.isAcceptableOrUnknown(data['concealed']!, _concealedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaultField map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultField(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      fieldType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_type'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      concealed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}concealed'],
      )!,
    );
  }

  @override
  $VaultFieldsTable createAlias(String alias) {
    return $VaultFieldsTable(attachedDatabase, alias);
  }
}

class VaultField extends DataClass implements Insertable<VaultField> {
  final String id;
  final String itemId;
  final String key;
  final String label;
  final String value;
  final String fieldType;
  final int sortOrder;
  final bool concealed;
  const VaultField({
    required this.id,
    required this.itemId,
    required this.key,
    required this.label,
    required this.value,
    required this.fieldType,
    required this.sortOrder,
    required this.concealed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['key'] = Variable<String>(key);
    map['label'] = Variable<String>(label);
    map['value'] = Variable<String>(value);
    map['field_type'] = Variable<String>(fieldType);
    map['sort_order'] = Variable<int>(sortOrder);
    map['concealed'] = Variable<bool>(concealed);
    return map;
  }

  VaultFieldsCompanion toCompanion(bool nullToAbsent) {
    return VaultFieldsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      key: Value(key),
      label: Value(label),
      value: Value(value),
      fieldType: Value(fieldType),
      sortOrder: Value(sortOrder),
      concealed: Value(concealed),
    );
  }

  factory VaultField.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultField(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      key: serializer.fromJson<String>(json['key']),
      label: serializer.fromJson<String>(json['label']),
      value: serializer.fromJson<String>(json['value']),
      fieldType: serializer.fromJson<String>(json['fieldType']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      concealed: serializer.fromJson<bool>(json['concealed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'key': serializer.toJson<String>(key),
      'label': serializer.toJson<String>(label),
      'value': serializer.toJson<String>(value),
      'fieldType': serializer.toJson<String>(fieldType),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'concealed': serializer.toJson<bool>(concealed),
    };
  }

  VaultField copyWith({
    String? id,
    String? itemId,
    String? key,
    String? label,
    String? value,
    String? fieldType,
    int? sortOrder,
    bool? concealed,
  }) => VaultField(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    key: key ?? this.key,
    label: label ?? this.label,
    value: value ?? this.value,
    fieldType: fieldType ?? this.fieldType,
    sortOrder: sortOrder ?? this.sortOrder,
    concealed: concealed ?? this.concealed,
  );
  VaultField copyWithCompanion(VaultFieldsCompanion data) {
    return VaultField(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      key: data.key.present ? data.key.value : this.key,
      label: data.label.present ? data.label.value : this.label,
      value: data.value.present ? data.value.value : this.value,
      fieldType: data.fieldType.present ? data.fieldType.value : this.fieldType,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      concealed: data.concealed.present ? data.concealed.value : this.concealed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultField(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('key: $key, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('fieldType: $fieldType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('concealed: $concealed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    key,
    label,
    value,
    fieldType,
    sortOrder,
    concealed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultField &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.key == this.key &&
          other.label == this.label &&
          other.value == this.value &&
          other.fieldType == this.fieldType &&
          other.sortOrder == this.sortOrder &&
          other.concealed == this.concealed);
}

class VaultFieldsCompanion extends UpdateCompanion<VaultField> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> key;
  final Value<String> label;
  final Value<String> value;
  final Value<String> fieldType;
  final Value<int> sortOrder;
  final Value<bool> concealed;
  final Value<int> rowid;
  const VaultFieldsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.key = const Value.absent(),
    this.label = const Value.absent(),
    this.value = const Value.absent(),
    this.fieldType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.concealed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultFieldsCompanion.insert({
    required String id,
    required String itemId,
    required String key,
    required String label,
    required String value,
    required String fieldType,
    required int sortOrder,
    this.concealed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       key = Value(key),
       label = Value(label),
       value = Value(value),
       fieldType = Value(fieldType),
       sortOrder = Value(sortOrder);
  static Insertable<VaultField> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? key,
    Expression<String>? label,
    Expression<String>? value,
    Expression<String>? fieldType,
    Expression<int>? sortOrder,
    Expression<bool>? concealed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      if (fieldType != null) 'field_type': fieldType,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (concealed != null) 'concealed': concealed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultFieldsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? key,
    Value<String>? label,
    Value<String>? value,
    Value<String>? fieldType,
    Value<int>? sortOrder,
    Value<bool>? concealed,
    Value<int>? rowid,
  }) {
    return VaultFieldsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      key: key ?? this.key,
      label: label ?? this.label,
      value: value ?? this.value,
      fieldType: fieldType ?? this.fieldType,
      sortOrder: sortOrder ?? this.sortOrder,
      concealed: concealed ?? this.concealed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (fieldType.present) {
      map['field_type'] = Variable<String>(fieldType.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (concealed.present) {
      map['concealed'] = Variable<bool>(concealed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultFieldsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('key: $key, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('fieldType: $fieldType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('concealed: $concealed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaultAttachmentsTable extends VaultAttachments
    with TableInfo<$VaultAttachmentsTable, VaultAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, itemId, label, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaultAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VaultAttachmentsTable createAlias(String alias) {
    return $VaultAttachmentsTable(attachedDatabase, alias);
  }
}

class VaultAttachment extends DataClass implements Insertable<VaultAttachment> {
  final String id;
  final String itemId;
  final String label;
  final DateTime createdAt;
  const VaultAttachment({
    required this.id,
    required this.itemId,
    required this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['label'] = Variable<String>(label);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VaultAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return VaultAttachmentsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      label: Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory VaultAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultAttachment(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      label: serializer.fromJson<String>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'label': serializer.toJson<String>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VaultAttachment copyWith({
    String? id,
    String? itemId,
    String? label,
    DateTime? createdAt,
  }) => VaultAttachment(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    label: label ?? this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  VaultAttachment copyWithCompanion(VaultAttachmentsCompanion data) {
    return VaultAttachment(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultAttachment(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultAttachment &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class VaultAttachmentsCompanion extends UpdateCompanion<VaultAttachment> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> label;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VaultAttachmentsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultAttachmentsCompanion.insert({
    required String id,
    required String itemId,
    required String label,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       label = Value(label),
       createdAt = Value(createdAt);
  static Insertable<VaultAttachment> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? label,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VaultAttachmentsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserCategoriesTable extends UserCategories
    with TableInfo<$UserCategoriesTable, UserCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldsJsonMeta = const VerificationMeta(
    'fieldsJson',
  );
  @override
  late final GeneratedColumn<String> fieldsJson = GeneratedColumn<String>(
    'fields_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    subtitle,
    iconCode,
    colorValue,
    fieldsJson,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('fields_json')) {
      context.handle(
        _fieldsJsonMeta,
        fieldsJson.isAcceptableOrUnknown(data['fields_json']!, _fieldsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsJsonMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      fieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields_json'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserCategoriesTable createAlias(String alias) {
    return $UserCategoriesTable(attachedDatabase, alias);
  }
}

class UserCategory extends DataClass implements Insertable<UserCategory> {
  final String id;
  final String label;
  final String subtitle;
  final int iconCode;
  final int colorValue;
  final String fieldsJson;
  final int sortOrder;
  final DateTime createdAt;
  const UserCategory({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.iconCode,
    required this.colorValue,
    required this.fieldsJson,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['subtitle'] = Variable<String>(subtitle);
    map['icon_code'] = Variable<int>(iconCode);
    map['color_value'] = Variable<int>(colorValue);
    map['fields_json'] = Variable<String>(fieldsJson);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserCategoriesCompanion toCompanion(bool nullToAbsent) {
    return UserCategoriesCompanion(
      id: Value(id),
      label: Value(label),
      subtitle: Value(subtitle),
      iconCode: Value(iconCode),
      colorValue: Value(colorValue),
      fieldsJson: Value(fieldsJson),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory UserCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCategory(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      fieldsJson: serializer.fromJson<String>(json['fieldsJson']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'subtitle': serializer.toJson<String>(subtitle),
      'iconCode': serializer.toJson<int>(iconCode),
      'colorValue': serializer.toJson<int>(colorValue),
      'fieldsJson': serializer.toJson<String>(fieldsJson),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserCategory copyWith({
    String? id,
    String? label,
    String? subtitle,
    int? iconCode,
    int? colorValue,
    String? fieldsJson,
    int? sortOrder,
    DateTime? createdAt,
  }) => UserCategory(
    id: id ?? this.id,
    label: label ?? this.label,
    subtitle: subtitle ?? this.subtitle,
    iconCode: iconCode ?? this.iconCode,
    colorValue: colorValue ?? this.colorValue,
    fieldsJson: fieldsJson ?? this.fieldsJson,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  UserCategory copyWithCompanion(UserCategoriesCompanion data) {
    return UserCategory(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      fieldsJson: data.fieldsJson.present
          ? data.fieldsJson.value
          : this.fieldsJson,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCategory(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('subtitle: $subtitle, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    subtitle,
    iconCode,
    colorValue,
    fieldsJson,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCategory &&
          other.id == this.id &&
          other.label == this.label &&
          other.subtitle == this.subtitle &&
          other.iconCode == this.iconCode &&
          other.colorValue == this.colorValue &&
          other.fieldsJson == this.fieldsJson &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class UserCategoriesCompanion extends UpdateCompanion<UserCategory> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> subtitle;
  final Value<int> iconCode;
  final Value<int> colorValue;
  final Value<String> fieldsJson;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserCategoriesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCategoriesCompanion.insert({
    required String id,
    required String label,
    this.subtitle = const Value.absent(),
    required int iconCode,
    required int colorValue,
    required String fieldsJson,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       iconCode = Value(iconCode),
       colorValue = Value(colorValue),
       fieldsJson = Value(fieldsJson),
       createdAt = Value(createdAt);
  static Insertable<UserCategory> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? subtitle,
    Expression<int>? iconCode,
    Expression<int>? colorValue,
    Expression<String>? fieldsJson,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (subtitle != null) 'subtitle': subtitle,
      if (iconCode != null) 'icon_code': iconCode,
      if (colorValue != null) 'color_value': colorValue,
      if (fieldsJson != null) 'fields_json': fieldsJson,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? subtitle,
    Value<int>? iconCode,
    Value<int>? colorValue,
    Value<String>? fieldsJson,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UserCategoriesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (fieldsJson.present) {
      map['fields_json'] = Variable<String>(fieldsJson.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('subtitle: $subtitle, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HiddenCategoriesTable extends HiddenCategories
    with TableInfo<$HiddenCategoriesTable, HiddenCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HiddenCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hidden_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<HiddenCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HiddenCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HiddenCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
    );
  }

  @override
  $HiddenCategoriesTable createAlias(String alias) {
    return $HiddenCategoriesTable(attachedDatabase, alias);
  }
}

class HiddenCategory extends DataClass implements Insertable<HiddenCategory> {
  final String id;
  const HiddenCategory({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    return map;
  }

  HiddenCategoriesCompanion toCompanion(bool nullToAbsent) {
    return HiddenCategoriesCompanion(id: Value(id));
  }

  factory HiddenCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HiddenCategory(id: serializer.fromJson<String>(json['id']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<String>(id)};
  }

  HiddenCategory copyWith({String? id}) => HiddenCategory(id: id ?? this.id);
  HiddenCategory copyWithCompanion(HiddenCategoriesCompanion data) {
    return HiddenCategory(id: data.id.present ? data.id.value : this.id);
  }

  @override
  String toString() {
    return (StringBuffer('HiddenCategory(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HiddenCategory && other.id == this.id);
}

class HiddenCategoriesCompanion extends UpdateCompanion<HiddenCategory> {
  final Value<String> id;
  final Value<int> rowid;
  const HiddenCategoriesCompanion({
    this.id = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HiddenCategoriesCompanion.insert({
    required String id,
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<HiddenCategory> custom({
    Expression<String>? id,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HiddenCategoriesCompanion copyWith({Value<String>? id, Value<int>? rowid}) {
    return HiddenCategoriesCompanion(
      id: id ?? this.id,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HiddenCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VaultDatabase extends GeneratedDatabase {
  _$VaultDatabase(QueryExecutor e) : super(e);
  $VaultDatabaseManager get managers => $VaultDatabaseManager(this);
  late final $VaultItemsTable vaultItems = $VaultItemsTable(this);
  late final $VaultFieldsTable vaultFields = $VaultFieldsTable(this);
  late final $VaultAttachmentsTable vaultAttachments = $VaultAttachmentsTable(
    this,
  );
  late final $UserCategoriesTable userCategories = $UserCategoriesTable(this);
  late final $HiddenCategoriesTable hiddenCategories = $HiddenCategoriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vaultItems,
    vaultFields,
    vaultAttachments,
    userCategories,
    hiddenCategories,
  ];
}

typedef $$VaultItemsTableCreateCompanionBuilder =
    VaultItemsCompanion Function({
      required String id,
      required String categoryId,
      required String title,
      Value<bool> favorite,
      Value<DateTime?> lastUsedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> notes,
      Value<String> tags,
      Value<int> rowid,
    });
typedef $$VaultItemsTableUpdateCompanionBuilder =
    VaultItemsCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<String> title,
      Value<bool> favorite,
      Value<DateTime?> lastUsedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> notes,
      Value<String> tags,
      Value<int> rowid,
    });

class $$VaultItemsTableFilterComposer
    extends Composer<_$VaultDatabase, $VaultItemsTable> {
  $$VaultItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaultItemsTableOrderingComposer
    extends Composer<_$VaultDatabase, $VaultItemsTable> {
  $$VaultItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultItemsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $VaultItemsTable> {
  $$VaultItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $$VaultItemsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $VaultItemsTable,
          VaultItem,
          $$VaultItemsTableFilterComposer,
          $$VaultItemsTableOrderingComposer,
          $$VaultItemsTableAnnotationComposer,
          $$VaultItemsTableCreateCompanionBuilder,
          $$VaultItemsTableUpdateCompanionBuilder,
          (
            VaultItem,
            BaseReferences<_$VaultDatabase, $VaultItemsTable, VaultItem>,
          ),
          VaultItem,
          PrefetchHooks Function()
        > {
  $$VaultItemsTableTableManager(_$VaultDatabase db, $VaultItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultItemsCompanion(
                id: id,
                categoryId: categoryId,
                title: title,
                favorite: favorite,
                lastUsedAt: lastUsedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                notes: notes,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required String title,
                Value<bool> favorite = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> notes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultItemsCompanion.insert(
                id: id,
                categoryId: categoryId,
                title: title,
                favorite: favorite,
                lastUsedAt: lastUsedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                notes: notes,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaultItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $VaultItemsTable,
      VaultItem,
      $$VaultItemsTableFilterComposer,
      $$VaultItemsTableOrderingComposer,
      $$VaultItemsTableAnnotationComposer,
      $$VaultItemsTableCreateCompanionBuilder,
      $$VaultItemsTableUpdateCompanionBuilder,
      (VaultItem, BaseReferences<_$VaultDatabase, $VaultItemsTable, VaultItem>),
      VaultItem,
      PrefetchHooks Function()
    >;
typedef $$VaultFieldsTableCreateCompanionBuilder =
    VaultFieldsCompanion Function({
      required String id,
      required String itemId,
      required String key,
      required String label,
      required String value,
      required String fieldType,
      required int sortOrder,
      Value<bool> concealed,
      Value<int> rowid,
    });
typedef $$VaultFieldsTableUpdateCompanionBuilder =
    VaultFieldsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String> key,
      Value<String> label,
      Value<String> value,
      Value<String> fieldType,
      Value<int> sortOrder,
      Value<bool> concealed,
      Value<int> rowid,
    });

class $$VaultFieldsTableFilterComposer
    extends Composer<_$VaultDatabase, $VaultFieldsTable> {
  $$VaultFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldType => $composableBuilder(
    column: $table.fieldType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get concealed => $composableBuilder(
    column: $table.concealed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaultFieldsTableOrderingComposer
    extends Composer<_$VaultDatabase, $VaultFieldsTable> {
  $$VaultFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldType => $composableBuilder(
    column: $table.fieldType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get concealed => $composableBuilder(
    column: $table.concealed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultFieldsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $VaultFieldsTable> {
  $$VaultFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get fieldType =>
      $composableBuilder(column: $table.fieldType, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get concealed =>
      $composableBuilder(column: $table.concealed, builder: (column) => column);
}

class $$VaultFieldsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $VaultFieldsTable,
          VaultField,
          $$VaultFieldsTableFilterComposer,
          $$VaultFieldsTableOrderingComposer,
          $$VaultFieldsTableAnnotationComposer,
          $$VaultFieldsTableCreateCompanionBuilder,
          $$VaultFieldsTableUpdateCompanionBuilder,
          (
            VaultField,
            BaseReferences<_$VaultDatabase, $VaultFieldsTable, VaultField>,
          ),
          VaultField,
          PrefetchHooks Function()
        > {
  $$VaultFieldsTableTableManager(_$VaultDatabase db, $VaultFieldsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultFieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultFieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultFieldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> fieldType = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> concealed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultFieldsCompanion(
                id: id,
                itemId: itemId,
                key: key,
                label: label,
                value: value,
                fieldType: fieldType,
                sortOrder: sortOrder,
                concealed: concealed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String key,
                required String label,
                required String value,
                required String fieldType,
                required int sortOrder,
                Value<bool> concealed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultFieldsCompanion.insert(
                id: id,
                itemId: itemId,
                key: key,
                label: label,
                value: value,
                fieldType: fieldType,
                sortOrder: sortOrder,
                concealed: concealed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaultFieldsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $VaultFieldsTable,
      VaultField,
      $$VaultFieldsTableFilterComposer,
      $$VaultFieldsTableOrderingComposer,
      $$VaultFieldsTableAnnotationComposer,
      $$VaultFieldsTableCreateCompanionBuilder,
      $$VaultFieldsTableUpdateCompanionBuilder,
      (
        VaultField,
        BaseReferences<_$VaultDatabase, $VaultFieldsTable, VaultField>,
      ),
      VaultField,
      PrefetchHooks Function()
    >;
typedef $$VaultAttachmentsTableCreateCompanionBuilder =
    VaultAttachmentsCompanion Function({
      required String id,
      required String itemId,
      required String label,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$VaultAttachmentsTableUpdateCompanionBuilder =
    VaultAttachmentsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String> label,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$VaultAttachmentsTableFilterComposer
    extends Composer<_$VaultDatabase, $VaultAttachmentsTable> {
  $$VaultAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaultAttachmentsTableOrderingComposer
    extends Composer<_$VaultDatabase, $VaultAttachmentsTable> {
  $$VaultAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultAttachmentsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $VaultAttachmentsTable> {
  $$VaultAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VaultAttachmentsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $VaultAttachmentsTable,
          VaultAttachment,
          $$VaultAttachmentsTableFilterComposer,
          $$VaultAttachmentsTableOrderingComposer,
          $$VaultAttachmentsTableAnnotationComposer,
          $$VaultAttachmentsTableCreateCompanionBuilder,
          $$VaultAttachmentsTableUpdateCompanionBuilder,
          (
            VaultAttachment,
            BaseReferences<
              _$VaultDatabase,
              $VaultAttachmentsTable,
              VaultAttachment
            >,
          ),
          VaultAttachment,
          PrefetchHooks Function()
        > {
  $$VaultAttachmentsTableTableManager(
    _$VaultDatabase db,
    $VaultAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultAttachmentsCompanion(
                id: id,
                itemId: itemId,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String label,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => VaultAttachmentsCompanion.insert(
                id: id,
                itemId: itemId,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaultAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $VaultAttachmentsTable,
      VaultAttachment,
      $$VaultAttachmentsTableFilterComposer,
      $$VaultAttachmentsTableOrderingComposer,
      $$VaultAttachmentsTableAnnotationComposer,
      $$VaultAttachmentsTableCreateCompanionBuilder,
      $$VaultAttachmentsTableUpdateCompanionBuilder,
      (
        VaultAttachment,
        BaseReferences<
          _$VaultDatabase,
          $VaultAttachmentsTable,
          VaultAttachment
        >,
      ),
      VaultAttachment,
      PrefetchHooks Function()
    >;
typedef $$UserCategoriesTableCreateCompanionBuilder =
    UserCategoriesCompanion Function({
      required String id,
      required String label,
      Value<String> subtitle,
      required int iconCode,
      required int colorValue,
      required String fieldsJson,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UserCategoriesTableUpdateCompanionBuilder =
    UserCategoriesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> subtitle,
      Value<int> iconCode,
      Value<int> colorValue,
      Value<String> fieldsJson,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UserCategoriesTableFilterComposer
    extends Composer<_$VaultDatabase, $UserCategoriesTable> {
  $$UserCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserCategoriesTableOrderingComposer
    extends Composer<_$VaultDatabase, $UserCategoriesTable> {
  $$UserCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserCategoriesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $UserCategoriesTable> {
  $$UserCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserCategoriesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $UserCategoriesTable,
          UserCategory,
          $$UserCategoriesTableFilterComposer,
          $$UserCategoriesTableOrderingComposer,
          $$UserCategoriesTableAnnotationComposer,
          $$UserCategoriesTableCreateCompanionBuilder,
          $$UserCategoriesTableUpdateCompanionBuilder,
          (
            UserCategory,
            BaseReferences<_$VaultDatabase, $UserCategoriesTable, UserCategory>,
          ),
          UserCategory,
          PrefetchHooks Function()
        > {
  $$UserCategoriesTableTableManager(
    _$VaultDatabase db,
    $UserCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String> fieldsJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserCategoriesCompanion(
                id: id,
                label: label,
                subtitle: subtitle,
                iconCode: iconCode,
                colorValue: colorValue,
                fieldsJson: fieldsJson,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                Value<String> subtitle = const Value.absent(),
                required int iconCode,
                required int colorValue,
                required String fieldsJson,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UserCategoriesCompanion.insert(
                id: id,
                label: label,
                subtitle: subtitle,
                iconCode: iconCode,
                colorValue: colorValue,
                fieldsJson: fieldsJson,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $UserCategoriesTable,
      UserCategory,
      $$UserCategoriesTableFilterComposer,
      $$UserCategoriesTableOrderingComposer,
      $$UserCategoriesTableAnnotationComposer,
      $$UserCategoriesTableCreateCompanionBuilder,
      $$UserCategoriesTableUpdateCompanionBuilder,
      (
        UserCategory,
        BaseReferences<_$VaultDatabase, $UserCategoriesTable, UserCategory>,
      ),
      UserCategory,
      PrefetchHooks Function()
    >;
typedef $$HiddenCategoriesTableCreateCompanionBuilder =
    HiddenCategoriesCompanion Function({required String id, Value<int> rowid});
typedef $$HiddenCategoriesTableUpdateCompanionBuilder =
    HiddenCategoriesCompanion Function({Value<String> id, Value<int> rowid});

class $$HiddenCategoriesTableFilterComposer
    extends Composer<_$VaultDatabase, $HiddenCategoriesTable> {
  $$HiddenCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HiddenCategoriesTableOrderingComposer
    extends Composer<_$VaultDatabase, $HiddenCategoriesTable> {
  $$HiddenCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HiddenCategoriesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $HiddenCategoriesTable> {
  $$HiddenCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$HiddenCategoriesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $HiddenCategoriesTable,
          HiddenCategory,
          $$HiddenCategoriesTableFilterComposer,
          $$HiddenCategoriesTableOrderingComposer,
          $$HiddenCategoriesTableAnnotationComposer,
          $$HiddenCategoriesTableCreateCompanionBuilder,
          $$HiddenCategoriesTableUpdateCompanionBuilder,
          (
            HiddenCategory,
            BaseReferences<
              _$VaultDatabase,
              $HiddenCategoriesTable,
              HiddenCategory
            >,
          ),
          HiddenCategory,
          PrefetchHooks Function()
        > {
  $$HiddenCategoriesTableTableManager(
    _$VaultDatabase db,
    $HiddenCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HiddenCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HiddenCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HiddenCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HiddenCategoriesCompanion(id: id, rowid: rowid),
          createCompanionCallback:
              ({required String id, Value<int> rowid = const Value.absent()}) =>
                  HiddenCategoriesCompanion.insert(id: id, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HiddenCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $HiddenCategoriesTable,
      HiddenCategory,
      $$HiddenCategoriesTableFilterComposer,
      $$HiddenCategoriesTableOrderingComposer,
      $$HiddenCategoriesTableAnnotationComposer,
      $$HiddenCategoriesTableCreateCompanionBuilder,
      $$HiddenCategoriesTableUpdateCompanionBuilder,
      (
        HiddenCategory,
        BaseReferences<_$VaultDatabase, $HiddenCategoriesTable, HiddenCategory>,
      ),
      HiddenCategory,
      PrefetchHooks Function()
    >;

class $VaultDatabaseManager {
  final _$VaultDatabase _db;
  $VaultDatabaseManager(this._db);
  $$VaultItemsTableTableManager get vaultItems =>
      $$VaultItemsTableTableManager(_db, _db.vaultItems);
  $$VaultFieldsTableTableManager get vaultFields =>
      $$VaultFieldsTableTableManager(_db, _db.vaultFields);
  $$VaultAttachmentsTableTableManager get vaultAttachments =>
      $$VaultAttachmentsTableTableManager(_db, _db.vaultAttachments);
  $$UserCategoriesTableTableManager get userCategories =>
      $$UserCategoriesTableTableManager(_db, _db.userCategories);
  $$HiddenCategoriesTableTableManager get hiddenCategories =>
      $$HiddenCategoriesTableTableManager(_db, _db.hiddenCategories);
}
