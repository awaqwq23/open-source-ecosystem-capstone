// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AgendaItemRowsTable extends AgendaItemRows
    with TableInfo<$AgendaItemRowsTable, AgendaItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgendaItemRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderMeta = const VerificationMeta(
    'reminder',
  );
  @override
  late final GeneratedColumn<String> reminder = GeneratedColumn<String>(
    'reminder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<double> sortOrder = GeneratedColumn<double>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceKindMeta = const VerificationMeta(
    'sourceKind',
  );
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _sourceRefMeta = const VerificationMeta(
    'sourceRef',
  );
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
    'source_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    notes,
    location,
    color,
    reminder,
    repeatRule,
    isCompleted,
    completedAt,
    sortOrder,
    sourceKind,
    sourceRef,
    remoteId,
    revision,
    dirty,
    deletedAt,
    lastSyncedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agenda_item_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgendaItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('reminder')) {
      context.handle(
        _reminderMeta,
        reminder.isAcceptableOrUnknown(data['reminder']!, _reminderMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderMeta);
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    } else if (isInserting) {
      context.missing(_repeatRuleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('source_kind')) {
      context.handle(
        _sourceKindMeta,
        sourceKind.isAcceptableOrUnknown(data['source_kind']!, _sourceKindMeta),
      );
    }
    if (data.containsKey('source_ref')) {
      context.handle(
        _sourceRefMeta,
        sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgendaItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgendaItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      reminder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder'],
      )!,
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sort_order'],
      )!,
      sourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_kind'],
      )!,
      sourceRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ref'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AgendaItemRowsTable createAlias(String alias) {
    return $AgendaItemRowsTable(attachedDatabase, alias);
  }
}

class AgendaItemRow extends DataClass implements Insertable<AgendaItemRow> {
  final String id;
  final String type;
  final String title;
  final String notes;
  final String location;
  final String color;
  final String reminder;
  final String repeatRule;
  final bool isCompleted;
  final DateTime? completedAt;
  final double sortOrder;
  final String sourceKind;
  final String sourceRef;
  final String? remoteId;
  final int revision;
  final bool dirty;
  final DateTime? deletedAt;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AgendaItemRow({
    required this.id,
    required this.type,
    required this.title,
    required this.notes,
    required this.location,
    required this.color,
    required this.reminder,
    required this.repeatRule,
    required this.isCompleted,
    this.completedAt,
    required this.sortOrder,
    required this.sourceKind,
    required this.sourceRef,
    this.remoteId,
    required this.revision,
    required this.dirty,
    this.deletedAt,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    map['location'] = Variable<String>(location);
    map['color'] = Variable<String>(color);
    map['reminder'] = Variable<String>(reminder);
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['sort_order'] = Variable<double>(sortOrder);
    map['source_kind'] = Variable<String>(sourceKind);
    map['source_ref'] = Variable<String>(sourceRef);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['revision'] = Variable<int>(revision);
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AgendaItemRowsCompanion toCompanion(bool nullToAbsent) {
    return AgendaItemRowsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      notes: Value(notes),
      location: Value(location),
      color: Value(color),
      reminder: Value(reminder),
      repeatRule: Value(repeatRule),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      sortOrder: Value(sortOrder),
      sourceKind: Value(sourceKind),
      sourceRef: Value(sourceRef),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      revision: Value(revision),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AgendaItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgendaItemRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      location: serializer.fromJson<String>(json['location']),
      color: serializer.fromJson<String>(json['color']),
      reminder: serializer.fromJson<String>(json['reminder']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
      sourceRef: serializer.fromJson<String>(json['sourceRef']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      revision: serializer.fromJson<int>(json['revision']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'location': serializer.toJson<String>(location),
      'color': serializer.toJson<String>(color),
      'reminder': serializer.toJson<String>(reminder),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'sortOrder': serializer.toJson<double>(sortOrder),
      'sourceKind': serializer.toJson<String>(sourceKind),
      'sourceRef': serializer.toJson<String>(sourceRef),
      'remoteId': serializer.toJson<String?>(remoteId),
      'revision': serializer.toJson<int>(revision),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AgendaItemRow copyWith({
    String? id,
    String? type,
    String? title,
    String? notes,
    String? location,
    String? color,
    String? reminder,
    String? repeatRule,
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    double? sortOrder,
    String? sourceKind,
    String? sourceRef,
    Value<String?> remoteId = const Value.absent(),
    int? revision,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AgendaItemRow(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    location: location ?? this.location,
    color: color ?? this.color,
    reminder: reminder ?? this.reminder,
    repeatRule: repeatRule ?? this.repeatRule,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    sortOrder: sortOrder ?? this.sortOrder,
    sourceKind: sourceKind ?? this.sourceKind,
    sourceRef: sourceRef ?? this.sourceRef,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    revision: revision ?? this.revision,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AgendaItemRow copyWithCompanion(AgendaItemRowsCompanion data) {
    return AgendaItemRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      location: data.location.present ? data.location.value : this.location,
      color: data.color.present ? data.color.value : this.color,
      reminder: data.reminder.present ? data.reminder.value : this.reminder,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      revision: data.revision.present ? data.revision.value : this.revision,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgendaItemRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('location: $location, ')
          ..write('color: $color, ')
          ..write('reminder: $reminder, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('remoteId: $remoteId, ')
          ..write('revision: $revision, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    notes,
    location,
    color,
    reminder,
    repeatRule,
    isCompleted,
    completedAt,
    sortOrder,
    sourceKind,
    sourceRef,
    remoteId,
    revision,
    dirty,
    deletedAt,
    lastSyncedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgendaItemRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.location == this.location &&
          other.color == this.color &&
          other.reminder == this.reminder &&
          other.repeatRule == this.repeatRule &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.sortOrder == this.sortOrder &&
          other.sourceKind == this.sourceKind &&
          other.sourceRef == this.sourceRef &&
          other.remoteId == this.remoteId &&
          other.revision == this.revision &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AgendaItemRowsCompanion extends UpdateCompanion<AgendaItemRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String> notes;
  final Value<String> location;
  final Value<String> color;
  final Value<String> reminder;
  final Value<String> repeatRule;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<double> sortOrder;
  final Value<String> sourceKind;
  final Value<String> sourceRef;
  final Value<String?> remoteId;
  final Value<int> revision;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AgendaItemRowsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.location = const Value.absent(),
    this.color = const Value.absent(),
    this.reminder = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.revision = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgendaItemRowsCompanion.insert({
    required String id,
    required String type,
    required String title,
    this.notes = const Value.absent(),
    this.location = const Value.absent(),
    required String color,
    required String reminder,
    required String repeatRule,
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.revision = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       title = Value(title),
       color = Value(color),
       reminder = Value(reminder),
       repeatRule = Value(repeatRule),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AgendaItemRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? location,
    Expression<String>? color,
    Expression<String>? reminder,
    Expression<String>? repeatRule,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<double>? sortOrder,
    Expression<String>? sourceKind,
    Expression<String>? sourceRef,
    Expression<String>? remoteId,
    Expression<int>? revision,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (location != null) 'location': location,
      if (color != null) 'color': color,
      if (reminder != null) 'reminder': reminder,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (remoteId != null) 'remote_id': remoteId,
      if (revision != null) 'revision': revision,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgendaItemRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? title,
    Value<String>? notes,
    Value<String>? location,
    Value<String>? color,
    Value<String>? reminder,
    Value<String>? repeatRule,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<double>? sortOrder,
    Value<String>? sourceKind,
    Value<String>? sourceRef,
    Value<String?>? remoteId,
    Value<int>? revision,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AgendaItemRowsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      color: color ?? this.color,
      reminder: reminder ?? this.reminder,
      repeatRule: repeatRule ?? this.repeatRule,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceRef: sourceRef ?? this.sourceRef,
      remoteId: remoteId ?? this.remoteId,
      revision: revision ?? this.revision,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (reminder.present) {
      map['reminder'] = Variable<String>(reminder.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<double>(sortOrder.value);
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgendaItemRowsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('location: $location, ')
          ..write('color: $color, ')
          ..write('reminder: $reminder, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('remoteId: $remoteId, ')
          ..write('revision: $revision, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleItemDetailRowsTable extends ScheduleItemDetailRows
    with TableInfo<$ScheduleItemDetailRowsTable, ScheduleItemDetailRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleItemDetailRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES agenda_item_rows (id)',
    ),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAllDayMeta = const VerificationMeta(
    'isAllDay',
  );
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
    'is_all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _countdownEnabledMeta = const VerificationMeta(
    'countdownEnabled',
  );
  @override
  late final GeneratedColumn<bool> countdownEnabled = GeneratedColumn<bool>(
    'countdown_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("countdown_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _autoCompletedOnceAtMeta =
      const VerificationMeta('autoCompletedOnceAt');
  @override
  late final GeneratedColumn<DateTime> autoCompletedOnceAt =
      GeneratedColumn<DateTime>(
        'auto_completed_once_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    startAt,
    endAt,
    isAllDay,
    countdownEnabled,
    autoCompletedOnceAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_item_detail_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleItemDetailRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('is_all_day')) {
      context.handle(
        _isAllDayMeta,
        isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta),
      );
    }
    if (data.containsKey('countdown_enabled')) {
      context.handle(
        _countdownEnabledMeta,
        countdownEnabled.isAcceptableOrUnknown(
          data['countdown_enabled']!,
          _countdownEnabledMeta,
        ),
      );
    }
    if (data.containsKey('auto_completed_once_at')) {
      context.handle(
        _autoCompletedOnceAtMeta,
        autoCompletedOnceAt.isAcceptableOrUnknown(
          data['auto_completed_once_at']!,
          _autoCompletedOnceAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  ScheduleItemDetailRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleItemDetailRow(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      )!,
      isAllDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_all_day'],
      )!,
      countdownEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}countdown_enabled'],
      )!,
      autoCompletedOnceAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}auto_completed_once_at'],
      ),
    );
  }

  @override
  $ScheduleItemDetailRowsTable createAlias(String alias) {
    return $ScheduleItemDetailRowsTable(attachedDatabase, alias);
  }
}

class ScheduleItemDetailRow extends DataClass
    implements Insertable<ScheduleItemDetailRow> {
  final String itemId;
  final DateTime startAt;
  final DateTime endAt;
  final bool isAllDay;
  final bool countdownEnabled;
  final DateTime? autoCompletedOnceAt;
  const ScheduleItemDetailRow({
    required this.itemId,
    required this.startAt,
    required this.endAt,
    required this.isAllDay,
    required this.countdownEnabled,
    this.autoCompletedOnceAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    map['is_all_day'] = Variable<bool>(isAllDay);
    map['countdown_enabled'] = Variable<bool>(countdownEnabled);
    if (!nullToAbsent || autoCompletedOnceAt != null) {
      map['auto_completed_once_at'] = Variable<DateTime>(autoCompletedOnceAt);
    }
    return map;
  }

  ScheduleItemDetailRowsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleItemDetailRowsCompanion(
      itemId: Value(itemId),
      startAt: Value(startAt),
      endAt: Value(endAt),
      isAllDay: Value(isAllDay),
      countdownEnabled: Value(countdownEnabled),
      autoCompletedOnceAt: autoCompletedOnceAt == null && nullToAbsent
          ? const Value.absent()
          : Value(autoCompletedOnceAt),
    );
  }

  factory ScheduleItemDetailRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleItemDetailRow(
      itemId: serializer.fromJson<String>(json['itemId']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      countdownEnabled: serializer.fromJson<bool>(json['countdownEnabled']),
      autoCompletedOnceAt: serializer.fromJson<DateTime?>(
        json['autoCompletedOnceAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'countdownEnabled': serializer.toJson<bool>(countdownEnabled),
      'autoCompletedOnceAt': serializer.toJson<DateTime?>(autoCompletedOnceAt),
    };
  }

  ScheduleItemDetailRow copyWith({
    String? itemId,
    DateTime? startAt,
    DateTime? endAt,
    bool? isAllDay,
    bool? countdownEnabled,
    Value<DateTime?> autoCompletedOnceAt = const Value.absent(),
  }) => ScheduleItemDetailRow(
    itemId: itemId ?? this.itemId,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    isAllDay: isAllDay ?? this.isAllDay,
    countdownEnabled: countdownEnabled ?? this.countdownEnabled,
    autoCompletedOnceAt: autoCompletedOnceAt.present
        ? autoCompletedOnceAt.value
        : this.autoCompletedOnceAt,
  );
  ScheduleItemDetailRow copyWithCompanion(
    ScheduleItemDetailRowsCompanion data,
  ) {
    return ScheduleItemDetailRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      countdownEnabled: data.countdownEnabled.present
          ? data.countdownEnabled.value
          : this.countdownEnabled,
      autoCompletedOnceAt: data.autoCompletedOnceAt.present
          ? data.autoCompletedOnceAt.value
          : this.autoCompletedOnceAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleItemDetailRow(')
          ..write('itemId: $itemId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('countdownEnabled: $countdownEnabled, ')
          ..write('autoCompletedOnceAt: $autoCompletedOnceAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemId,
    startAt,
    endAt,
    isAllDay,
    countdownEnabled,
    autoCompletedOnceAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleItemDetailRow &&
          other.itemId == this.itemId &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.isAllDay == this.isAllDay &&
          other.countdownEnabled == this.countdownEnabled &&
          other.autoCompletedOnceAt == this.autoCompletedOnceAt);
}

class ScheduleItemDetailRowsCompanion
    extends UpdateCompanion<ScheduleItemDetailRow> {
  final Value<String> itemId;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<bool> isAllDay;
  final Value<bool> countdownEnabled;
  final Value<DateTime?> autoCompletedOnceAt;
  final Value<int> rowid;
  const ScheduleItemDetailRowsCompanion({
    this.itemId = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.countdownEnabled = const Value.absent(),
    this.autoCompletedOnceAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleItemDetailRowsCompanion.insert({
    required String itemId,
    required DateTime startAt,
    required DateTime endAt,
    this.isAllDay = const Value.absent(),
    this.countdownEnabled = const Value.absent(),
    this.autoCompletedOnceAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       startAt = Value(startAt),
       endAt = Value(endAt);
  static Insertable<ScheduleItemDetailRow> custom({
    Expression<String>? itemId,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<bool>? isAllDay,
    Expression<bool>? countdownEnabled,
    Expression<DateTime>? autoCompletedOnceAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (countdownEnabled != null) 'countdown_enabled': countdownEnabled,
      if (autoCompletedOnceAt != null)
        'auto_completed_once_at': autoCompletedOnceAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleItemDetailRowsCompanion copyWith({
    Value<String>? itemId,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<bool>? isAllDay,
    Value<bool>? countdownEnabled,
    Value<DateTime?>? autoCompletedOnceAt,
    Value<int>? rowid,
  }) {
    return ScheduleItemDetailRowsCompanion(
      itemId: itemId ?? this.itemId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isAllDay: isAllDay ?? this.isAllDay,
      countdownEnabled: countdownEnabled ?? this.countdownEnabled,
      autoCompletedOnceAt: autoCompletedOnceAt ?? this.autoCompletedOnceAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (countdownEnabled.present) {
      map['countdown_enabled'] = Variable<bool>(countdownEnabled.value);
    }
    if (autoCompletedOnceAt.present) {
      map['auto_completed_once_at'] = Variable<DateTime>(
        autoCompletedOnceAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleItemDetailRowsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('countdownEnabled: $countdownEnabled, ')
          ..write('autoCompletedOnceAt: $autoCompletedOnceAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskItemDetailRowsTable extends TaskItemDetailRows
    with TableInfo<$TaskItemDetailRowsTable, TaskItemDetailRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskItemDetailRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES agenda_item_rows (id)',
    ),
  );
  static const VerificationMeta _deadlineAtMeta = const VerificationMeta(
    'deadlineAt',
  );
  @override
  late final GeneratedColumn<DateTime> deadlineAt = GeneratedColumn<DateTime>(
    'deadline_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, deadlineAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_item_detail_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskItemDetailRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('deadline_at')) {
      context.handle(
        _deadlineAtMeta,
        deadlineAt.isAcceptableOrUnknown(data['deadline_at']!, _deadlineAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deadlineAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  TaskItemDetailRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskItemDetailRow(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      deadlineAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline_at'],
      )!,
    );
  }

  @override
  $TaskItemDetailRowsTable createAlias(String alias) {
    return $TaskItemDetailRowsTable(attachedDatabase, alias);
  }
}

class TaskItemDetailRow extends DataClass
    implements Insertable<TaskItemDetailRow> {
  final String itemId;
  final DateTime deadlineAt;
  const TaskItemDetailRow({required this.itemId, required this.deadlineAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['deadline_at'] = Variable<DateTime>(deadlineAt);
    return map;
  }

  TaskItemDetailRowsCompanion toCompanion(bool nullToAbsent) {
    return TaskItemDetailRowsCompanion(
      itemId: Value(itemId),
      deadlineAt: Value(deadlineAt),
    );
  }

  factory TaskItemDetailRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskItemDetailRow(
      itemId: serializer.fromJson<String>(json['itemId']),
      deadlineAt: serializer.fromJson<DateTime>(json['deadlineAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'deadlineAt': serializer.toJson<DateTime>(deadlineAt),
    };
  }

  TaskItemDetailRow copyWith({String? itemId, DateTime? deadlineAt}) =>
      TaskItemDetailRow(
        itemId: itemId ?? this.itemId,
        deadlineAt: deadlineAt ?? this.deadlineAt,
      );
  TaskItemDetailRow copyWithCompanion(TaskItemDetailRowsCompanion data) {
    return TaskItemDetailRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      deadlineAt: data.deadlineAt.present
          ? data.deadlineAt.value
          : this.deadlineAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskItemDetailRow(')
          ..write('itemId: $itemId, ')
          ..write('deadlineAt: $deadlineAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, deadlineAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskItemDetailRow &&
          other.itemId == this.itemId &&
          other.deadlineAt == this.deadlineAt);
}

class TaskItemDetailRowsCompanion extends UpdateCompanion<TaskItemDetailRow> {
  final Value<String> itemId;
  final Value<DateTime> deadlineAt;
  final Value<int> rowid;
  const TaskItemDetailRowsCompanion({
    this.itemId = const Value.absent(),
    this.deadlineAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskItemDetailRowsCompanion.insert({
    required String itemId,
    required DateTime deadlineAt,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       deadlineAt = Value(deadlineAt);
  static Insertable<TaskItemDetailRow> custom({
    Expression<String>? itemId,
    Expression<DateTime>? deadlineAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (deadlineAt != null) 'deadline_at': deadlineAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskItemDetailRowsCompanion copyWith({
    Value<String>? itemId,
    Value<DateTime>? deadlineAt,
    Value<int>? rowid,
  }) {
    return TaskItemDetailRowsCompanion(
      itemId: itemId ?? this.itemId,
      deadlineAt: deadlineAt ?? this.deadlineAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (deadlineAt.present) {
      map['deadline_at'] = Variable<DateTime>(deadlineAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskItemDetailRowsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseItemDetailRowsTable extends CourseItemDetailRows
    with TableInfo<$CourseItemDetailRowsTable, CourseItemDetailRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseItemDetailRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES agenda_item_rows (id)',
    ),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAllDayMeta = const VerificationMeta(
    'isAllDay',
  );
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
    'is_all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timetableIdMeta = const VerificationMeta(
    'timetableId',
  );
  @override
  late final GeneratedColumn<String> timetableId = GeneratedColumn<String>(
    'timetable_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceKindMeta = const VerificationMeta(
    'sourceKind',
  );
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _sourceCourseIdMeta = const VerificationMeta(
    'sourceCourseId',
  );
  @override
  late final GeneratedColumn<String> sourceCourseId = GeneratedColumn<String>(
    'source_course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseNatureMeta = const VerificationMeta(
    'courseNature',
  );
  @override
  late final GeneratedColumn<String> courseNature = GeneratedColumn<String>(
    'course_nature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _instructorMeta = const VerificationMeta(
    'instructor',
  );
  @override
  late final GeneratedColumn<String> instructor = GeneratedColumn<String>(
    'instructor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _weekMetaMeta = const VerificationMeta(
    'weekMeta',
  );
  @override
  late final GeneratedColumn<String> weekMeta = GeneratedColumn<String>(
    'week_meta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _termCourseIdMeta = const VerificationMeta(
    'termCourseId',
  );
  @override
  late final GeneratedColumn<String> termCourseId = GeneratedColumn<String>(
    'term_course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _offeringIdMeta = const VerificationMeta(
    'offeringId',
  );
  @override
  late final GeneratedColumn<String> offeringId = GeneratedColumn<String>(
    'offering_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _instructorCourseIdMeta =
      const VerificationMeta('instructorCourseId');
  @override
  late final GeneratedColumn<String> instructorCourseId =
      GeneratedColumn<String>(
        'instructor_course_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _occurrenceIdMeta = const VerificationMeta(
    'occurrenceId',
  );
  @override
  late final GeneratedColumn<String> occurrenceId = GeneratedColumn<String>(
    'occurrence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    startAt,
    endAt,
    isAllDay,
    timetableId,
    sourceKind,
    sourceCourseId,
    courseNature,
    instructor,
    weekMeta,
    termCourseId,
    offeringId,
    instructorCourseId,
    occurrenceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_item_detail_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseItemDetailRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('is_all_day')) {
      context.handle(
        _isAllDayMeta,
        isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta),
      );
    }
    if (data.containsKey('timetable_id')) {
      context.handle(
        _timetableIdMeta,
        timetableId.isAcceptableOrUnknown(
          data['timetable_id']!,
          _timetableIdMeta,
        ),
      );
    }
    if (data.containsKey('source_kind')) {
      context.handle(
        _sourceKindMeta,
        sourceKind.isAcceptableOrUnknown(data['source_kind']!, _sourceKindMeta),
      );
    }
    if (data.containsKey('source_course_id')) {
      context.handle(
        _sourceCourseIdMeta,
        sourceCourseId.isAcceptableOrUnknown(
          data['source_course_id']!,
          _sourceCourseIdMeta,
        ),
      );
    }
    if (data.containsKey('course_nature')) {
      context.handle(
        _courseNatureMeta,
        courseNature.isAcceptableOrUnknown(
          data['course_nature']!,
          _courseNatureMeta,
        ),
      );
    }
    if (data.containsKey('instructor')) {
      context.handle(
        _instructorMeta,
        instructor.isAcceptableOrUnknown(data['instructor']!, _instructorMeta),
      );
    }
    if (data.containsKey('week_meta')) {
      context.handle(
        _weekMetaMeta,
        weekMeta.isAcceptableOrUnknown(data['week_meta']!, _weekMetaMeta),
      );
    }
    if (data.containsKey('term_course_id')) {
      context.handle(
        _termCourseIdMeta,
        termCourseId.isAcceptableOrUnknown(
          data['term_course_id']!,
          _termCourseIdMeta,
        ),
      );
    }
    if (data.containsKey('offering_id')) {
      context.handle(
        _offeringIdMeta,
        offeringId.isAcceptableOrUnknown(data['offering_id']!, _offeringIdMeta),
      );
    }
    if (data.containsKey('instructor_course_id')) {
      context.handle(
        _instructorCourseIdMeta,
        instructorCourseId.isAcceptableOrUnknown(
          data['instructor_course_id']!,
          _instructorCourseIdMeta,
        ),
      );
    }
    if (data.containsKey('occurrence_id')) {
      context.handle(
        _occurrenceIdMeta,
        occurrenceId.isAcceptableOrUnknown(
          data['occurrence_id']!,
          _occurrenceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  CourseItemDetailRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseItemDetailRow(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      )!,
      isAllDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_all_day'],
      )!,
      timetableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timetable_id'],
      )!,
      sourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_kind'],
      )!,
      sourceCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_course_id'],
      )!,
      courseNature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_nature'],
      )!,
      instructor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructor'],
      )!,
      weekMeta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_meta'],
      )!,
      termCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_course_id'],
      )!,
      offeringId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offering_id'],
      )!,
      instructorCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructor_course_id'],
      )!,
      occurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_id'],
      )!,
    );
  }

  @override
  $CourseItemDetailRowsTable createAlias(String alias) {
    return $CourseItemDetailRowsTable(attachedDatabase, alias);
  }
}

class CourseItemDetailRow extends DataClass
    implements Insertable<CourseItemDetailRow> {
  final String itemId;
  final DateTime startAt;
  final DateTime endAt;
  final bool isAllDay;
  final String timetableId;
  final String sourceKind;
  final String sourceCourseId;
  final String courseNature;
  final String instructor;
  final String weekMeta;
  final String termCourseId;
  final String offeringId;
  final String instructorCourseId;
  final String occurrenceId;
  const CourseItemDetailRow({
    required this.itemId,
    required this.startAt,
    required this.endAt,
    required this.isAllDay,
    required this.timetableId,
    required this.sourceKind,
    required this.sourceCourseId,
    required this.courseNature,
    required this.instructor,
    required this.weekMeta,
    required this.termCourseId,
    required this.offeringId,
    required this.instructorCourseId,
    required this.occurrenceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    map['is_all_day'] = Variable<bool>(isAllDay);
    map['timetable_id'] = Variable<String>(timetableId);
    map['source_kind'] = Variable<String>(sourceKind);
    map['source_course_id'] = Variable<String>(sourceCourseId);
    map['course_nature'] = Variable<String>(courseNature);
    map['instructor'] = Variable<String>(instructor);
    map['week_meta'] = Variable<String>(weekMeta);
    map['term_course_id'] = Variable<String>(termCourseId);
    map['offering_id'] = Variable<String>(offeringId);
    map['instructor_course_id'] = Variable<String>(instructorCourseId);
    map['occurrence_id'] = Variable<String>(occurrenceId);
    return map;
  }

  CourseItemDetailRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseItemDetailRowsCompanion(
      itemId: Value(itemId),
      startAt: Value(startAt),
      endAt: Value(endAt),
      isAllDay: Value(isAllDay),
      timetableId: Value(timetableId),
      sourceKind: Value(sourceKind),
      sourceCourseId: Value(sourceCourseId),
      courseNature: Value(courseNature),
      instructor: Value(instructor),
      weekMeta: Value(weekMeta),
      termCourseId: Value(termCourseId),
      offeringId: Value(offeringId),
      instructorCourseId: Value(instructorCourseId),
      occurrenceId: Value(occurrenceId),
    );
  }

  factory CourseItemDetailRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseItemDetailRow(
      itemId: serializer.fromJson<String>(json['itemId']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      timetableId: serializer.fromJson<String>(json['timetableId']),
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
      sourceCourseId: serializer.fromJson<String>(json['sourceCourseId']),
      courseNature: serializer.fromJson<String>(json['courseNature']),
      instructor: serializer.fromJson<String>(json['instructor']),
      weekMeta: serializer.fromJson<String>(json['weekMeta']),
      termCourseId: serializer.fromJson<String>(json['termCourseId']),
      offeringId: serializer.fromJson<String>(json['offeringId']),
      instructorCourseId: serializer.fromJson<String>(
        json['instructorCourseId'],
      ),
      occurrenceId: serializer.fromJson<String>(json['occurrenceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'timetableId': serializer.toJson<String>(timetableId),
      'sourceKind': serializer.toJson<String>(sourceKind),
      'sourceCourseId': serializer.toJson<String>(sourceCourseId),
      'courseNature': serializer.toJson<String>(courseNature),
      'instructor': serializer.toJson<String>(instructor),
      'weekMeta': serializer.toJson<String>(weekMeta),
      'termCourseId': serializer.toJson<String>(termCourseId),
      'offeringId': serializer.toJson<String>(offeringId),
      'instructorCourseId': serializer.toJson<String>(instructorCourseId),
      'occurrenceId': serializer.toJson<String>(occurrenceId),
    };
  }

  CourseItemDetailRow copyWith({
    String? itemId,
    DateTime? startAt,
    DateTime? endAt,
    bool? isAllDay,
    String? timetableId,
    String? sourceKind,
    String? sourceCourseId,
    String? courseNature,
    String? instructor,
    String? weekMeta,
    String? termCourseId,
    String? offeringId,
    String? instructorCourseId,
    String? occurrenceId,
  }) => CourseItemDetailRow(
    itemId: itemId ?? this.itemId,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    isAllDay: isAllDay ?? this.isAllDay,
    timetableId: timetableId ?? this.timetableId,
    sourceKind: sourceKind ?? this.sourceKind,
    sourceCourseId: sourceCourseId ?? this.sourceCourseId,
    courseNature: courseNature ?? this.courseNature,
    instructor: instructor ?? this.instructor,
    weekMeta: weekMeta ?? this.weekMeta,
    termCourseId: termCourseId ?? this.termCourseId,
    offeringId: offeringId ?? this.offeringId,
    instructorCourseId: instructorCourseId ?? this.instructorCourseId,
    occurrenceId: occurrenceId ?? this.occurrenceId,
  );
  CourseItemDetailRow copyWithCompanion(CourseItemDetailRowsCompanion data) {
    return CourseItemDetailRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      timetableId: data.timetableId.present
          ? data.timetableId.value
          : this.timetableId,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      sourceCourseId: data.sourceCourseId.present
          ? data.sourceCourseId.value
          : this.sourceCourseId,
      courseNature: data.courseNature.present
          ? data.courseNature.value
          : this.courseNature,
      instructor: data.instructor.present
          ? data.instructor.value
          : this.instructor,
      weekMeta: data.weekMeta.present ? data.weekMeta.value : this.weekMeta,
      termCourseId: data.termCourseId.present
          ? data.termCourseId.value
          : this.termCourseId,
      offeringId: data.offeringId.present
          ? data.offeringId.value
          : this.offeringId,
      instructorCourseId: data.instructorCourseId.present
          ? data.instructorCourseId.value
          : this.instructorCourseId,
      occurrenceId: data.occurrenceId.present
          ? data.occurrenceId.value
          : this.occurrenceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseItemDetailRow(')
          ..write('itemId: $itemId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('timetableId: $timetableId, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceCourseId: $sourceCourseId, ')
          ..write('courseNature: $courseNature, ')
          ..write('instructor: $instructor, ')
          ..write('weekMeta: $weekMeta, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('offeringId: $offeringId, ')
          ..write('instructorCourseId: $instructorCourseId, ')
          ..write('occurrenceId: $occurrenceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemId,
    startAt,
    endAt,
    isAllDay,
    timetableId,
    sourceKind,
    sourceCourseId,
    courseNature,
    instructor,
    weekMeta,
    termCourseId,
    offeringId,
    instructorCourseId,
    occurrenceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseItemDetailRow &&
          other.itemId == this.itemId &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.isAllDay == this.isAllDay &&
          other.timetableId == this.timetableId &&
          other.sourceKind == this.sourceKind &&
          other.sourceCourseId == this.sourceCourseId &&
          other.courseNature == this.courseNature &&
          other.instructor == this.instructor &&
          other.weekMeta == this.weekMeta &&
          other.termCourseId == this.termCourseId &&
          other.offeringId == this.offeringId &&
          other.instructorCourseId == this.instructorCourseId &&
          other.occurrenceId == this.occurrenceId);
}

class CourseItemDetailRowsCompanion
    extends UpdateCompanion<CourseItemDetailRow> {
  final Value<String> itemId;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<bool> isAllDay;
  final Value<String> timetableId;
  final Value<String> sourceKind;
  final Value<String> sourceCourseId;
  final Value<String> courseNature;
  final Value<String> instructor;
  final Value<String> weekMeta;
  final Value<String> termCourseId;
  final Value<String> offeringId;
  final Value<String> instructorCourseId;
  final Value<String> occurrenceId;
  final Value<int> rowid;
  const CourseItemDetailRowsCompanion({
    this.itemId = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.timetableId = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.sourceCourseId = const Value.absent(),
    this.courseNature = const Value.absent(),
    this.instructor = const Value.absent(),
    this.weekMeta = const Value.absent(),
    this.termCourseId = const Value.absent(),
    this.offeringId = const Value.absent(),
    this.instructorCourseId = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseItemDetailRowsCompanion.insert({
    required String itemId,
    required DateTime startAt,
    required DateTime endAt,
    this.isAllDay = const Value.absent(),
    this.timetableId = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.sourceCourseId = const Value.absent(),
    this.courseNature = const Value.absent(),
    this.instructor = const Value.absent(),
    this.weekMeta = const Value.absent(),
    this.termCourseId = const Value.absent(),
    this.offeringId = const Value.absent(),
    this.instructorCourseId = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       startAt = Value(startAt),
       endAt = Value(endAt);
  static Insertable<CourseItemDetailRow> custom({
    Expression<String>? itemId,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<bool>? isAllDay,
    Expression<String>? timetableId,
    Expression<String>? sourceKind,
    Expression<String>? sourceCourseId,
    Expression<String>? courseNature,
    Expression<String>? instructor,
    Expression<String>? weekMeta,
    Expression<String>? termCourseId,
    Expression<String>? offeringId,
    Expression<String>? instructorCourseId,
    Expression<String>? occurrenceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (timetableId != null) 'timetable_id': timetableId,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (sourceCourseId != null) 'source_course_id': sourceCourseId,
      if (courseNature != null) 'course_nature': courseNature,
      if (instructor != null) 'instructor': instructor,
      if (weekMeta != null) 'week_meta': weekMeta,
      if (termCourseId != null) 'term_course_id': termCourseId,
      if (offeringId != null) 'offering_id': offeringId,
      if (instructorCourseId != null)
        'instructor_course_id': instructorCourseId,
      if (occurrenceId != null) 'occurrence_id': occurrenceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseItemDetailRowsCompanion copyWith({
    Value<String>? itemId,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<bool>? isAllDay,
    Value<String>? timetableId,
    Value<String>? sourceKind,
    Value<String>? sourceCourseId,
    Value<String>? courseNature,
    Value<String>? instructor,
    Value<String>? weekMeta,
    Value<String>? termCourseId,
    Value<String>? offeringId,
    Value<String>? instructorCourseId,
    Value<String>? occurrenceId,
    Value<int>? rowid,
  }) {
    return CourseItemDetailRowsCompanion(
      itemId: itemId ?? this.itemId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isAllDay: isAllDay ?? this.isAllDay,
      timetableId: timetableId ?? this.timetableId,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceCourseId: sourceCourseId ?? this.sourceCourseId,
      courseNature: courseNature ?? this.courseNature,
      instructor: instructor ?? this.instructor,
      weekMeta: weekMeta ?? this.weekMeta,
      termCourseId: termCourseId ?? this.termCourseId,
      offeringId: offeringId ?? this.offeringId,
      instructorCourseId: instructorCourseId ?? this.instructorCourseId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (timetableId.present) {
      map['timetable_id'] = Variable<String>(timetableId.value);
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
    }
    if (sourceCourseId.present) {
      map['source_course_id'] = Variable<String>(sourceCourseId.value);
    }
    if (courseNature.present) {
      map['course_nature'] = Variable<String>(courseNature.value);
    }
    if (instructor.present) {
      map['instructor'] = Variable<String>(instructor.value);
    }
    if (weekMeta.present) {
      map['week_meta'] = Variable<String>(weekMeta.value);
    }
    if (termCourseId.present) {
      map['term_course_id'] = Variable<String>(termCourseId.value);
    }
    if (offeringId.present) {
      map['offering_id'] = Variable<String>(offeringId.value);
    }
    if (instructorCourseId.present) {
      map['instructor_course_id'] = Variable<String>(instructorCourseId.value);
    }
    if (occurrenceId.present) {
      map['occurrence_id'] = Variable<String>(occurrenceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseItemDetailRowsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('timetableId: $timetableId, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceCourseId: $sourceCourseId, ')
          ..write('courseNature: $courseNature, ')
          ..write('instructor: $instructor, ')
          ..write('weekMeta: $weekMeta, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('offeringId: $offeringId, ')
          ..write('instructorCourseId: $instructorCourseId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseTimetableRowsTable extends CourseTimetableRows
    with TableInfo<$CourseTimetableRowsTable, CourseTimetableRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseTimetableRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termLabelMeta = const VerificationMeta(
    'termLabel',
  );
  @override
  late final GeneratedColumn<String> termLabel = GeneratedColumn<String>(
    'term_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    source,
    termLabel,
    remoteId,
    revision,
    dirty,
    deletedAt,
    lastSyncedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_timetable_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseTimetableRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('term_label')) {
      context.handle(
        _termLabelMeta,
        termLabel.isAcceptableOrUnknown(data['term_label']!, _termLabelMeta),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseTimetableRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseTimetableRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      termLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_label'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CourseTimetableRowsTable createAlias(String alias) {
    return $CourseTimetableRowsTable(attachedDatabase, alias);
  }
}

class CourseTimetableRow extends DataClass
    implements Insertable<CourseTimetableRow> {
  final String id;
  final String name;
  final String source;
  final String termLabel;
  final String? remoteId;
  final int revision;
  final bool dirty;
  final DateTime? deletedAt;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CourseTimetableRow({
    required this.id,
    required this.name,
    required this.source,
    required this.termLabel,
    this.remoteId,
    required this.revision,
    required this.dirty,
    this.deletedAt,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['source'] = Variable<String>(source);
    map['term_label'] = Variable<String>(termLabel);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['revision'] = Variable<int>(revision);
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CourseTimetableRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseTimetableRowsCompanion(
      id: Value(id),
      name: Value(name),
      source: Value(source),
      termLabel: Value(termLabel),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      revision: Value(revision),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CourseTimetableRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseTimetableRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String>(json['source']),
      termLabel: serializer.fromJson<String>(json['termLabel']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      revision: serializer.fromJson<int>(json['revision']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String>(source),
      'termLabel': serializer.toJson<String>(termLabel),
      'remoteId': serializer.toJson<String?>(remoteId),
      'revision': serializer.toJson<int>(revision),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CourseTimetableRow copyWith({
    String? id,
    String? name,
    String? source,
    String? termLabel,
    Value<String?> remoteId = const Value.absent(),
    int? revision,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CourseTimetableRow(
    id: id ?? this.id,
    name: name ?? this.name,
    source: source ?? this.source,
    termLabel: termLabel ?? this.termLabel,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    revision: revision ?? this.revision,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CourseTimetableRow copyWithCompanion(CourseTimetableRowsCompanion data) {
    return CourseTimetableRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
      termLabel: data.termLabel.present ? data.termLabel.value : this.termLabel,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      revision: data.revision.present ? data.revision.value : this.revision,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseTimetableRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('termLabel: $termLabel, ')
          ..write('remoteId: $remoteId, ')
          ..write('revision: $revision, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    source,
    termLabel,
    remoteId,
    revision,
    dirty,
    deletedAt,
    lastSyncedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseTimetableRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.source == this.source &&
          other.termLabel == this.termLabel &&
          other.remoteId == this.remoteId &&
          other.revision == this.revision &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CourseTimetableRowsCompanion extends UpdateCompanion<CourseTimetableRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> source;
  final Value<String> termLabel;
  final Value<String?> remoteId;
  final Value<int> revision;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CourseTimetableRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.termLabel = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.revision = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseTimetableRowsCompanion.insert({
    required String id,
    required String name,
    required String source,
    this.termLabel = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.revision = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CourseTimetableRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? source,
    Expression<String>? termLabel,
    Expression<String>? remoteId,
    Expression<int>? revision,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (termLabel != null) 'term_label': termLabel,
      if (remoteId != null) 'remote_id': remoteId,
      if (revision != null) 'revision': revision,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseTimetableRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? source,
    Value<String>? termLabel,
    Value<String?>? remoteId,
    Value<int>? revision,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CourseTimetableRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      termLabel: termLabel ?? this.termLabel,
      remoteId: remoteId ?? this.remoteId,
      revision: revision ?? this.revision,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (termLabel.present) {
      map['term_label'] = Variable<String>(termLabel.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseTimetableRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('termLabel: $termLabel, ')
          ..write('remoteId: $remoteId, ')
          ..write('revision: $revision, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SelectedCourseTimetableRowsTable extends SelectedCourseTimetableRows
    with
        TableInfo<
          $SelectedCourseTimetableRowsTable,
          SelectedCourseTimetableRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SelectedCourseTimetableRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _timetableIdMeta = const VerificationMeta(
    'timetableId',
  );
  @override
  late final GeneratedColumn<String> timetableId = GeneratedColumn<String>(
    'timetable_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_timetable_rows (id)',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<double> sortOrder = GeneratedColumn<double>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    timetableId,
    sortOrder,
    revision,
    dirty,
    deletedAt,
    lastSyncedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'selected_course_timetable_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SelectedCourseTimetableRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('timetable_id')) {
      context.handle(
        _timetableIdMeta,
        timetableId.isAcceptableOrUnknown(
          data['timetable_id']!,
          _timetableIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timetableIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {timetableId};
  @override
  SelectedCourseTimetableRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SelectedCourseTimetableRow(
      timetableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timetable_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sort_order'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SelectedCourseTimetableRowsTable createAlias(String alias) {
    return $SelectedCourseTimetableRowsTable(attachedDatabase, alias);
  }
}

class SelectedCourseTimetableRow extends DataClass
    implements Insertable<SelectedCourseTimetableRow> {
  final String timetableId;
  final double sortOrder;
  final int revision;
  final bool dirty;
  final DateTime? deletedAt;
  final DateTime? lastSyncedAt;
  final DateTime updatedAt;
  const SelectedCourseTimetableRow({
    required this.timetableId,
    required this.sortOrder,
    required this.revision,
    required this.dirty,
    this.deletedAt,
    this.lastSyncedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['timetable_id'] = Variable<String>(timetableId);
    map['sort_order'] = Variable<double>(sortOrder);
    map['revision'] = Variable<int>(revision);
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SelectedCourseTimetableRowsCompanion toCompanion(bool nullToAbsent) {
    return SelectedCourseTimetableRowsCompanion(
      timetableId: Value(timetableId),
      sortOrder: Value(sortOrder),
      revision: Value(revision),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SelectedCourseTimetableRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SelectedCourseTimetableRow(
      timetableId: serializer.fromJson<String>(json['timetableId']),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
      revision: serializer.fromJson<int>(json['revision']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'timetableId': serializer.toJson<String>(timetableId),
      'sortOrder': serializer.toJson<double>(sortOrder),
      'revision': serializer.toJson<int>(revision),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SelectedCourseTimetableRow copyWith({
    String? timetableId,
    double? sortOrder,
    int? revision,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => SelectedCourseTimetableRow(
    timetableId: timetableId ?? this.timetableId,
    sortOrder: sortOrder ?? this.sortOrder,
    revision: revision ?? this.revision,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SelectedCourseTimetableRow copyWithCompanion(
    SelectedCourseTimetableRowsCompanion data,
  ) {
    return SelectedCourseTimetableRow(
      timetableId: data.timetableId.present
          ? data.timetableId.value
          : this.timetableId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      revision: data.revision.present ? data.revision.value : this.revision,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SelectedCourseTimetableRow(')
          ..write('timetableId: $timetableId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('revision: $revision, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    timetableId,
    sortOrder,
    revision,
    dirty,
    deletedAt,
    lastSyncedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelectedCourseTimetableRow &&
          other.timetableId == this.timetableId &&
          other.sortOrder == this.sortOrder &&
          other.revision == this.revision &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.updatedAt == this.updatedAt);
}

class SelectedCourseTimetableRowsCompanion
    extends UpdateCompanion<SelectedCourseTimetableRow> {
  final Value<String> timetableId;
  final Value<double> sortOrder;
  final Value<int> revision;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SelectedCourseTimetableRowsCompanion({
    this.timetableId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.revision = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SelectedCourseTimetableRowsCompanion.insert({
    required String timetableId,
    this.sortOrder = const Value.absent(),
    this.revision = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : timetableId = Value(timetableId),
       updatedAt = Value(updatedAt);
  static Insertable<SelectedCourseTimetableRow> custom({
    Expression<String>? timetableId,
    Expression<double>? sortOrder,
    Expression<int>? revision,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (timetableId != null) 'timetable_id': timetableId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (revision != null) 'revision': revision,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SelectedCourseTimetableRowsCompanion copyWith({
    Value<String>? timetableId,
    Value<double>? sortOrder,
    Value<int>? revision,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SelectedCourseTimetableRowsCompanion(
      timetableId: timetableId ?? this.timetableId,
      sortOrder: sortOrder ?? this.sortOrder,
      revision: revision ?? this.revision,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (timetableId.present) {
      map['timetable_id'] = Variable<String>(timetableId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<double>(sortOrder.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SelectedCourseTimetableRowsCompanion(')
          ..write('timetableId: $timetableId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('revision: $revision, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchoolTimetableTermRowsTable extends SchoolTimetableTermRows
    with TableInfo<$SchoolTimetableTermRowsTable, SchoolTimetableTermRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolTimetableTermRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _termKeyMeta = const VerificationMeta(
    'termKey',
  );
  @override
  late final GeneratedColumn<String> termKey = GeneratedColumn<String>(
    'term_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolYearMeta = const VerificationMeta(
    'schoolYear',
  );
  @override
  late final GeneratedColumn<String> schoolYear = GeneratedColumn<String>(
    'school_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstWeekMondayMeta = const VerificationMeta(
    'firstWeekMonday',
  );
  @override
  late final GeneratedColumn<String> firstWeekMonday = GeneratedColumn<String>(
    'first_week_monday',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceVersionMeta = const VerificationMeta(
    'sourceVersion',
  );
  @override
  late final GeneratedColumn<String> sourceVersion = GeneratedColumn<String>(
    'source_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rowCountMeta = const VerificationMeta(
    'rowCount',
  );
  @override
  late final GeneratedColumn<int> rowCount = GeneratedColumn<int>(
    'row_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
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
  @override
  List<GeneratedColumn> get $columns => [
    termKey,
    schoolYear,
    term,
    firstWeekMonday,
    sourceVersion,
    rowCount,
    importedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'school_timetable_term_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolTimetableTermRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('term_key')) {
      context.handle(
        _termKeyMeta,
        termKey.isAcceptableOrUnknown(data['term_key']!, _termKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_termKeyMeta);
    }
    if (data.containsKey('school_year')) {
      context.handle(
        _schoolYearMeta,
        schoolYear.isAcceptableOrUnknown(data['school_year']!, _schoolYearMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolYearMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('first_week_monday')) {
      context.handle(
        _firstWeekMondayMeta,
        firstWeekMonday.isAcceptableOrUnknown(
          data['first_week_monday']!,
          _firstWeekMondayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstWeekMondayMeta);
    }
    if (data.containsKey('source_version')) {
      context.handle(
        _sourceVersionMeta,
        sourceVersion.isAcceptableOrUnknown(
          data['source_version']!,
          _sourceVersionMeta,
        ),
      );
    }
    if (data.containsKey('row_count')) {
      context.handle(
        _rowCountMeta,
        rowCount.isAcceptableOrUnknown(data['row_count']!, _rowCountMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {termKey};
  @override
  SchoolTimetableTermRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolTimetableTermRow(
      termKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_key'],
      )!,
      schoolYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_year'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      firstWeekMonday: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_week_monday'],
      )!,
      sourceVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_version'],
      )!,
      rowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_count'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SchoolTimetableTermRowsTable createAlias(String alias) {
    return $SchoolTimetableTermRowsTable(attachedDatabase, alias);
  }
}

class SchoolTimetableTermRow extends DataClass
    implements Insertable<SchoolTimetableTermRow> {
  final String termKey;
  final String schoolYear;
  final String term;
  final String firstWeekMonday;
  final String sourceVersion;
  final int rowCount;
  final DateTime importedAt;
  final DateTime updatedAt;
  const SchoolTimetableTermRow({
    required this.termKey,
    required this.schoolYear,
    required this.term,
    required this.firstWeekMonday,
    required this.sourceVersion,
    required this.rowCount,
    required this.importedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['term_key'] = Variable<String>(termKey);
    map['school_year'] = Variable<String>(schoolYear);
    map['term'] = Variable<String>(term);
    map['first_week_monday'] = Variable<String>(firstWeekMonday);
    map['source_version'] = Variable<String>(sourceVersion);
    map['row_count'] = Variable<int>(rowCount);
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SchoolTimetableTermRowsCompanion toCompanion(bool nullToAbsent) {
    return SchoolTimetableTermRowsCompanion(
      termKey: Value(termKey),
      schoolYear: Value(schoolYear),
      term: Value(term),
      firstWeekMonday: Value(firstWeekMonday),
      sourceVersion: Value(sourceVersion),
      rowCount: Value(rowCount),
      importedAt: Value(importedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SchoolTimetableTermRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchoolTimetableTermRow(
      termKey: serializer.fromJson<String>(json['termKey']),
      schoolYear: serializer.fromJson<String>(json['schoolYear']),
      term: serializer.fromJson<String>(json['term']),
      firstWeekMonday: serializer.fromJson<String>(json['firstWeekMonday']),
      sourceVersion: serializer.fromJson<String>(json['sourceVersion']),
      rowCount: serializer.fromJson<int>(json['rowCount']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'termKey': serializer.toJson<String>(termKey),
      'schoolYear': serializer.toJson<String>(schoolYear),
      'term': serializer.toJson<String>(term),
      'firstWeekMonday': serializer.toJson<String>(firstWeekMonday),
      'sourceVersion': serializer.toJson<String>(sourceVersion),
      'rowCount': serializer.toJson<int>(rowCount),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SchoolTimetableTermRow copyWith({
    String? termKey,
    String? schoolYear,
    String? term,
    String? firstWeekMonday,
    String? sourceVersion,
    int? rowCount,
    DateTime? importedAt,
    DateTime? updatedAt,
  }) => SchoolTimetableTermRow(
    termKey: termKey ?? this.termKey,
    schoolYear: schoolYear ?? this.schoolYear,
    term: term ?? this.term,
    firstWeekMonday: firstWeekMonday ?? this.firstWeekMonday,
    sourceVersion: sourceVersion ?? this.sourceVersion,
    rowCount: rowCount ?? this.rowCount,
    importedAt: importedAt ?? this.importedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SchoolTimetableTermRow copyWithCompanion(
    SchoolTimetableTermRowsCompanion data,
  ) {
    return SchoolTimetableTermRow(
      termKey: data.termKey.present ? data.termKey.value : this.termKey,
      schoolYear: data.schoolYear.present
          ? data.schoolYear.value
          : this.schoolYear,
      term: data.term.present ? data.term.value : this.term,
      firstWeekMonday: data.firstWeekMonday.present
          ? data.firstWeekMonday.value
          : this.firstWeekMonday,
      sourceVersion: data.sourceVersion.present
          ? data.sourceVersion.value
          : this.sourceVersion,
      rowCount: data.rowCount.present ? data.rowCount.value : this.rowCount,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchoolTimetableTermRow(')
          ..write('termKey: $termKey, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('term: $term, ')
          ..write('firstWeekMonday: $firstWeekMonday, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('rowCount: $rowCount, ')
          ..write('importedAt: $importedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    termKey,
    schoolYear,
    term,
    firstWeekMonday,
    sourceVersion,
    rowCount,
    importedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchoolTimetableTermRow &&
          other.termKey == this.termKey &&
          other.schoolYear == this.schoolYear &&
          other.term == this.term &&
          other.firstWeekMonday == this.firstWeekMonday &&
          other.sourceVersion == this.sourceVersion &&
          other.rowCount == this.rowCount &&
          other.importedAt == this.importedAt &&
          other.updatedAt == this.updatedAt);
}

class SchoolTimetableTermRowsCompanion
    extends UpdateCompanion<SchoolTimetableTermRow> {
  final Value<String> termKey;
  final Value<String> schoolYear;
  final Value<String> term;
  final Value<String> firstWeekMonday;
  final Value<String> sourceVersion;
  final Value<int> rowCount;
  final Value<DateTime> importedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SchoolTimetableTermRowsCompanion({
    this.termKey = const Value.absent(),
    this.schoolYear = const Value.absent(),
    this.term = const Value.absent(),
    this.firstWeekMonday = const Value.absent(),
    this.sourceVersion = const Value.absent(),
    this.rowCount = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolTimetableTermRowsCompanion.insert({
    required String termKey,
    required String schoolYear,
    required String term,
    required String firstWeekMonday,
    this.sourceVersion = const Value.absent(),
    this.rowCount = const Value.absent(),
    required DateTime importedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : termKey = Value(termKey),
       schoolYear = Value(schoolYear),
       term = Value(term),
       firstWeekMonday = Value(firstWeekMonday),
       importedAt = Value(importedAt),
       updatedAt = Value(updatedAt);
  static Insertable<SchoolTimetableTermRow> custom({
    Expression<String>? termKey,
    Expression<String>? schoolYear,
    Expression<String>? term,
    Expression<String>? firstWeekMonday,
    Expression<String>? sourceVersion,
    Expression<int>? rowCount,
    Expression<DateTime>? importedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (termKey != null) 'term_key': termKey,
      if (schoolYear != null) 'school_year': schoolYear,
      if (term != null) 'term': term,
      if (firstWeekMonday != null) 'first_week_monday': firstWeekMonday,
      if (sourceVersion != null) 'source_version': sourceVersion,
      if (rowCount != null) 'row_count': rowCount,
      if (importedAt != null) 'imported_at': importedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolTimetableTermRowsCompanion copyWith({
    Value<String>? termKey,
    Value<String>? schoolYear,
    Value<String>? term,
    Value<String>? firstWeekMonday,
    Value<String>? sourceVersion,
    Value<int>? rowCount,
    Value<DateTime>? importedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SchoolTimetableTermRowsCompanion(
      termKey: termKey ?? this.termKey,
      schoolYear: schoolYear ?? this.schoolYear,
      term: term ?? this.term,
      firstWeekMonday: firstWeekMonday ?? this.firstWeekMonday,
      sourceVersion: sourceVersion ?? this.sourceVersion,
      rowCount: rowCount ?? this.rowCount,
      importedAt: importedAt ?? this.importedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (termKey.present) {
      map['term_key'] = Variable<String>(termKey.value);
    }
    if (schoolYear.present) {
      map['school_year'] = Variable<String>(schoolYear.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (firstWeekMonday.present) {
      map['first_week_monday'] = Variable<String>(firstWeekMonday.value);
    }
    if (sourceVersion.present) {
      map['source_version'] = Variable<String>(sourceVersion.value);
    }
    if (rowCount.present) {
      map['row_count'] = Variable<int>(rowCount.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolTimetableTermRowsCompanion(')
          ..write('termKey: $termKey, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('term: $term, ')
          ..write('firstWeekMonday: $firstWeekMonday, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('rowCount: $rowCount, ')
          ..write('importedAt: $importedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseCatalogRowsTable extends CourseCatalogRows
    with TableInfo<$CourseCatalogRowsTable, CourseCatalogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseCatalogRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogKeyMeta = const VerificationMeta(
    'catalogKey',
  );
  @override
  late final GeneratedColumn<String> catalogKey = GeneratedColumn<String>(
    'catalog_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseNoMeta = const VerificationMeta(
    'courseNo',
  );
  @override
  late final GeneratedColumn<String> courseNo = GeneratedColumn<String>(
    'course_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  @override
  late final GeneratedColumn<double> credits = GeneratedColumn<double>(
    'credits',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catalogKey,
    courseNo,
    courseName,
    credits,
    searchText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_catalog_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseCatalogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('catalog_key')) {
      context.handle(
        _catalogKeyMeta,
        catalogKey.isAcceptableOrUnknown(data['catalog_key']!, _catalogKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogKeyMeta);
    }
    if (data.containsKey('course_no')) {
      context.handle(
        _courseNoMeta,
        courseNo.isAcceptableOrUnknown(data['course_no']!, _courseNoMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNoMeta);
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNameMeta);
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseCatalogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseCatalogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      catalogKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_key'],
      )!,
      courseNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_no'],
      )!,
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credits'],
      ),
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
    );
  }

  @override
  $CourseCatalogRowsTable createAlias(String alias) {
    return $CourseCatalogRowsTable(attachedDatabase, alias);
  }
}

class CourseCatalogRow extends DataClass
    implements Insertable<CourseCatalogRow> {
  final String id;
  final String catalogKey;
  final String courseNo;
  final String courseName;
  final double? credits;
  final String searchText;
  const CourseCatalogRow({
    required this.id,
    required this.catalogKey,
    required this.courseNo,
    required this.courseName,
    this.credits,
    required this.searchText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['catalog_key'] = Variable<String>(catalogKey);
    map['course_no'] = Variable<String>(courseNo);
    map['course_name'] = Variable<String>(courseName);
    if (!nullToAbsent || credits != null) {
      map['credits'] = Variable<double>(credits);
    }
    map['search_text'] = Variable<String>(searchText);
    return map;
  }

  CourseCatalogRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseCatalogRowsCompanion(
      id: Value(id),
      catalogKey: Value(catalogKey),
      courseNo: Value(courseNo),
      courseName: Value(courseName),
      credits: credits == null && nullToAbsent
          ? const Value.absent()
          : Value(credits),
      searchText: Value(searchText),
    );
  }

  factory CourseCatalogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseCatalogRow(
      id: serializer.fromJson<String>(json['id']),
      catalogKey: serializer.fromJson<String>(json['catalogKey']),
      courseNo: serializer.fromJson<String>(json['courseNo']),
      courseName: serializer.fromJson<String>(json['courseName']),
      credits: serializer.fromJson<double?>(json['credits']),
      searchText: serializer.fromJson<String>(json['searchText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'catalogKey': serializer.toJson<String>(catalogKey),
      'courseNo': serializer.toJson<String>(courseNo),
      'courseName': serializer.toJson<String>(courseName),
      'credits': serializer.toJson<double?>(credits),
      'searchText': serializer.toJson<String>(searchText),
    };
  }

  CourseCatalogRow copyWith({
    String? id,
    String? catalogKey,
    String? courseNo,
    String? courseName,
    Value<double?> credits = const Value.absent(),
    String? searchText,
  }) => CourseCatalogRow(
    id: id ?? this.id,
    catalogKey: catalogKey ?? this.catalogKey,
    courseNo: courseNo ?? this.courseNo,
    courseName: courseName ?? this.courseName,
    credits: credits.present ? credits.value : this.credits,
    searchText: searchText ?? this.searchText,
  );
  CourseCatalogRow copyWithCompanion(CourseCatalogRowsCompanion data) {
    return CourseCatalogRow(
      id: data.id.present ? data.id.value : this.id,
      catalogKey: data.catalogKey.present
          ? data.catalogKey.value
          : this.catalogKey,
      courseNo: data.courseNo.present ? data.courseNo.value : this.courseNo,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      credits: data.credits.present ? data.credits.value : this.credits,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseCatalogRow(')
          ..write('id: $id, ')
          ..write('catalogKey: $catalogKey, ')
          ..write('courseNo: $courseNo, ')
          ..write('courseName: $courseName, ')
          ..write('credits: $credits, ')
          ..write('searchText: $searchText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, catalogKey, courseNo, courseName, credits, searchText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseCatalogRow &&
          other.id == this.id &&
          other.catalogKey == this.catalogKey &&
          other.courseNo == this.courseNo &&
          other.courseName == this.courseName &&
          other.credits == this.credits &&
          other.searchText == this.searchText);
}

class CourseCatalogRowsCompanion extends UpdateCompanion<CourseCatalogRow> {
  final Value<String> id;
  final Value<String> catalogKey;
  final Value<String> courseNo;
  final Value<String> courseName;
  final Value<double?> credits;
  final Value<String> searchText;
  final Value<int> rowid;
  const CourseCatalogRowsCompanion({
    this.id = const Value.absent(),
    this.catalogKey = const Value.absent(),
    this.courseNo = const Value.absent(),
    this.courseName = const Value.absent(),
    this.credits = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseCatalogRowsCompanion.insert({
    required String id,
    required String catalogKey,
    required String courseNo,
    required String courseName,
    this.credits = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       catalogKey = Value(catalogKey),
       courseNo = Value(courseNo),
       courseName = Value(courseName);
  static Insertable<CourseCatalogRow> custom({
    Expression<String>? id,
    Expression<String>? catalogKey,
    Expression<String>? courseNo,
    Expression<String>? courseName,
    Expression<double>? credits,
    Expression<String>? searchText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catalogKey != null) 'catalog_key': catalogKey,
      if (courseNo != null) 'course_no': courseNo,
      if (courseName != null) 'course_name': courseName,
      if (credits != null) 'credits': credits,
      if (searchText != null) 'search_text': searchText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseCatalogRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? catalogKey,
    Value<String>? courseNo,
    Value<String>? courseName,
    Value<double?>? credits,
    Value<String>? searchText,
    Value<int>? rowid,
  }) {
    return CourseCatalogRowsCompanion(
      id: id ?? this.id,
      catalogKey: catalogKey ?? this.catalogKey,
      courseNo: courseNo ?? this.courseNo,
      courseName: courseName ?? this.courseName,
      credits: credits ?? this.credits,
      searchText: searchText ?? this.searchText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (catalogKey.present) {
      map['catalog_key'] = Variable<String>(catalogKey.value);
    }
    if (courseNo.present) {
      map['course_no'] = Variable<String>(courseNo.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (credits.present) {
      map['credits'] = Variable<double>(credits.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseCatalogRowsCompanion(')
          ..write('id: $id, ')
          ..write('catalogKey: $catalogKey, ')
          ..write('courseNo: $courseNo, ')
          ..write('courseName: $courseName, ')
          ..write('credits: $credits, ')
          ..write('searchText: $searchText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseTermCourseRowsTable extends CourseTermCourseRows
    with TableInfo<$CourseTermCourseRowsTable, CourseTermCourseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseTermCourseRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termKeyMeta = const VerificationMeta(
    'termKey',
  );
  @override
  late final GeneratedColumn<String> termKey = GeneratedColumn<String>(
    'term_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES school_timetable_term_rows (term_key)',
    ),
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_catalog_rows (id)',
    ),
  );
  static const VerificationMeta _courseNoMeta = const VerificationMeta(
    'courseNo',
  );
  @override
  late final GeneratedColumn<String> courseNo = GeneratedColumn<String>(
    'course_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openCollegeMeta = const VerificationMeta(
    'openCollege',
  );
  @override
  late final GeneratedColumn<String> openCollege = GeneratedColumn<String>(
    'open_college',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  @override
  late final GeneratedColumn<double> credits = GeneratedColumn<double>(
    'credits',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseNatureMeta = const VerificationMeta(
    'courseNature',
  );
  @override
  late final GeneratedColumn<String> courseNature = GeneratedColumn<String>(
    'course_nature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseCategoryMeta = const VerificationMeta(
    'courseCategory',
  );
  @override
  late final GeneratedColumn<String> courseCategory = GeneratedColumn<String>(
    'course_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _openTypeMeta = const VerificationMeta(
    'openType',
  );
  @override
  late final GeneratedColumn<String> openType = GeneratedColumn<String>(
    'open_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _teachingClassCountMeta =
      const VerificationMeta('teachingClassCount');
  @override
  late final GeneratedColumn<int> teachingClassCount = GeneratedColumn<int>(
    'teaching_class_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _teacherSummaryMeta = const VerificationMeta(
    'teacherSummary',
  );
  @override
  late final GeneratedColumn<String> teacherSummary = GeneratedColumn<String>(
    'teacher_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _weekdaySummaryMeta = const VerificationMeta(
    'weekdaySummary',
  );
  @override
  late final GeneratedColumn<String> weekdaySummary = GeneratedColumn<String>(
    'weekday_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    termKey,
    catalogId,
    courseNo,
    courseName,
    openCollege,
    credits,
    courseNature,
    courseCategory,
    openType,
    teachingClassCount,
    teacherSummary,
    weekdaySummary,
    searchText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_term_course_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseTermCourseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('term_key')) {
      context.handle(
        _termKeyMeta,
        termKey.isAcceptableOrUnknown(data['term_key']!, _termKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_termKeyMeta);
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('course_no')) {
      context.handle(
        _courseNoMeta,
        courseNo.isAcceptableOrUnknown(data['course_no']!, _courseNoMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNoMeta);
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNameMeta);
    }
    if (data.containsKey('open_college')) {
      context.handle(
        _openCollegeMeta,
        openCollege.isAcceptableOrUnknown(
          data['open_college']!,
          _openCollegeMeta,
        ),
      );
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    }
    if (data.containsKey('course_nature')) {
      context.handle(
        _courseNatureMeta,
        courseNature.isAcceptableOrUnknown(
          data['course_nature']!,
          _courseNatureMeta,
        ),
      );
    }
    if (data.containsKey('course_category')) {
      context.handle(
        _courseCategoryMeta,
        courseCategory.isAcceptableOrUnknown(
          data['course_category']!,
          _courseCategoryMeta,
        ),
      );
    }
    if (data.containsKey('open_type')) {
      context.handle(
        _openTypeMeta,
        openType.isAcceptableOrUnknown(data['open_type']!, _openTypeMeta),
      );
    }
    if (data.containsKey('teaching_class_count')) {
      context.handle(
        _teachingClassCountMeta,
        teachingClassCount.isAcceptableOrUnknown(
          data['teaching_class_count']!,
          _teachingClassCountMeta,
        ),
      );
    }
    if (data.containsKey('teacher_summary')) {
      context.handle(
        _teacherSummaryMeta,
        teacherSummary.isAcceptableOrUnknown(
          data['teacher_summary']!,
          _teacherSummaryMeta,
        ),
      );
    }
    if (data.containsKey('weekday_summary')) {
      context.handle(
        _weekdaySummaryMeta,
        weekdaySummary.isAcceptableOrUnknown(
          data['weekday_summary']!,
          _weekdaySummaryMeta,
        ),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseTermCourseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseTermCourseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      termKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_key'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      courseNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_no'],
      )!,
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      )!,
      openCollege: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_college'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credits'],
      ),
      courseNature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_nature'],
      )!,
      courseCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_category'],
      )!,
      openType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_type'],
      )!,
      teachingClassCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}teaching_class_count'],
      )!,
      teacherSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_summary'],
      )!,
      weekdaySummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekday_summary'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
    );
  }

  @override
  $CourseTermCourseRowsTable createAlias(String alias) {
    return $CourseTermCourseRowsTable(attachedDatabase, alias);
  }
}

class CourseTermCourseRow extends DataClass
    implements Insertable<CourseTermCourseRow> {
  final String id;
  final String termKey;
  final String catalogId;
  final String courseNo;
  final String courseName;
  final String openCollege;
  final double? credits;
  final String courseNature;
  final String courseCategory;
  final String openType;
  final int teachingClassCount;
  final String teacherSummary;
  final String weekdaySummary;
  final String searchText;
  const CourseTermCourseRow({
    required this.id,
    required this.termKey,
    required this.catalogId,
    required this.courseNo,
    required this.courseName,
    required this.openCollege,
    this.credits,
    required this.courseNature,
    required this.courseCategory,
    required this.openType,
    required this.teachingClassCount,
    required this.teacherSummary,
    required this.weekdaySummary,
    required this.searchText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['term_key'] = Variable<String>(termKey);
    map['catalog_id'] = Variable<String>(catalogId);
    map['course_no'] = Variable<String>(courseNo);
    map['course_name'] = Variable<String>(courseName);
    map['open_college'] = Variable<String>(openCollege);
    if (!nullToAbsent || credits != null) {
      map['credits'] = Variable<double>(credits);
    }
    map['course_nature'] = Variable<String>(courseNature);
    map['course_category'] = Variable<String>(courseCategory);
    map['open_type'] = Variable<String>(openType);
    map['teaching_class_count'] = Variable<int>(teachingClassCount);
    map['teacher_summary'] = Variable<String>(teacherSummary);
    map['weekday_summary'] = Variable<String>(weekdaySummary);
    map['search_text'] = Variable<String>(searchText);
    return map;
  }

  CourseTermCourseRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseTermCourseRowsCompanion(
      id: Value(id),
      termKey: Value(termKey),
      catalogId: Value(catalogId),
      courseNo: Value(courseNo),
      courseName: Value(courseName),
      openCollege: Value(openCollege),
      credits: credits == null && nullToAbsent
          ? const Value.absent()
          : Value(credits),
      courseNature: Value(courseNature),
      courseCategory: Value(courseCategory),
      openType: Value(openType),
      teachingClassCount: Value(teachingClassCount),
      teacherSummary: Value(teacherSummary),
      weekdaySummary: Value(weekdaySummary),
      searchText: Value(searchText),
    );
  }

  factory CourseTermCourseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseTermCourseRow(
      id: serializer.fromJson<String>(json['id']),
      termKey: serializer.fromJson<String>(json['termKey']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      courseNo: serializer.fromJson<String>(json['courseNo']),
      courseName: serializer.fromJson<String>(json['courseName']),
      openCollege: serializer.fromJson<String>(json['openCollege']),
      credits: serializer.fromJson<double?>(json['credits']),
      courseNature: serializer.fromJson<String>(json['courseNature']),
      courseCategory: serializer.fromJson<String>(json['courseCategory']),
      openType: serializer.fromJson<String>(json['openType']),
      teachingClassCount: serializer.fromJson<int>(json['teachingClassCount']),
      teacherSummary: serializer.fromJson<String>(json['teacherSummary']),
      weekdaySummary: serializer.fromJson<String>(json['weekdaySummary']),
      searchText: serializer.fromJson<String>(json['searchText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'termKey': serializer.toJson<String>(termKey),
      'catalogId': serializer.toJson<String>(catalogId),
      'courseNo': serializer.toJson<String>(courseNo),
      'courseName': serializer.toJson<String>(courseName),
      'openCollege': serializer.toJson<String>(openCollege),
      'credits': serializer.toJson<double?>(credits),
      'courseNature': serializer.toJson<String>(courseNature),
      'courseCategory': serializer.toJson<String>(courseCategory),
      'openType': serializer.toJson<String>(openType),
      'teachingClassCount': serializer.toJson<int>(teachingClassCount),
      'teacherSummary': serializer.toJson<String>(teacherSummary),
      'weekdaySummary': serializer.toJson<String>(weekdaySummary),
      'searchText': serializer.toJson<String>(searchText),
    };
  }

  CourseTermCourseRow copyWith({
    String? id,
    String? termKey,
    String? catalogId,
    String? courseNo,
    String? courseName,
    String? openCollege,
    Value<double?> credits = const Value.absent(),
    String? courseNature,
    String? courseCategory,
    String? openType,
    int? teachingClassCount,
    String? teacherSummary,
    String? weekdaySummary,
    String? searchText,
  }) => CourseTermCourseRow(
    id: id ?? this.id,
    termKey: termKey ?? this.termKey,
    catalogId: catalogId ?? this.catalogId,
    courseNo: courseNo ?? this.courseNo,
    courseName: courseName ?? this.courseName,
    openCollege: openCollege ?? this.openCollege,
    credits: credits.present ? credits.value : this.credits,
    courseNature: courseNature ?? this.courseNature,
    courseCategory: courseCategory ?? this.courseCategory,
    openType: openType ?? this.openType,
    teachingClassCount: teachingClassCount ?? this.teachingClassCount,
    teacherSummary: teacherSummary ?? this.teacherSummary,
    weekdaySummary: weekdaySummary ?? this.weekdaySummary,
    searchText: searchText ?? this.searchText,
  );
  CourseTermCourseRow copyWithCompanion(CourseTermCourseRowsCompanion data) {
    return CourseTermCourseRow(
      id: data.id.present ? data.id.value : this.id,
      termKey: data.termKey.present ? data.termKey.value : this.termKey,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      courseNo: data.courseNo.present ? data.courseNo.value : this.courseNo,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      openCollege: data.openCollege.present
          ? data.openCollege.value
          : this.openCollege,
      credits: data.credits.present ? data.credits.value : this.credits,
      courseNature: data.courseNature.present
          ? data.courseNature.value
          : this.courseNature,
      courseCategory: data.courseCategory.present
          ? data.courseCategory.value
          : this.courseCategory,
      openType: data.openType.present ? data.openType.value : this.openType,
      teachingClassCount: data.teachingClassCount.present
          ? data.teachingClassCount.value
          : this.teachingClassCount,
      teacherSummary: data.teacherSummary.present
          ? data.teacherSummary.value
          : this.teacherSummary,
      weekdaySummary: data.weekdaySummary.present
          ? data.weekdaySummary.value
          : this.weekdaySummary,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseTermCourseRow(')
          ..write('id: $id, ')
          ..write('termKey: $termKey, ')
          ..write('catalogId: $catalogId, ')
          ..write('courseNo: $courseNo, ')
          ..write('courseName: $courseName, ')
          ..write('openCollege: $openCollege, ')
          ..write('credits: $credits, ')
          ..write('courseNature: $courseNature, ')
          ..write('courseCategory: $courseCategory, ')
          ..write('openType: $openType, ')
          ..write('teachingClassCount: $teachingClassCount, ')
          ..write('teacherSummary: $teacherSummary, ')
          ..write('weekdaySummary: $weekdaySummary, ')
          ..write('searchText: $searchText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    termKey,
    catalogId,
    courseNo,
    courseName,
    openCollege,
    credits,
    courseNature,
    courseCategory,
    openType,
    teachingClassCount,
    teacherSummary,
    weekdaySummary,
    searchText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseTermCourseRow &&
          other.id == this.id &&
          other.termKey == this.termKey &&
          other.catalogId == this.catalogId &&
          other.courseNo == this.courseNo &&
          other.courseName == this.courseName &&
          other.openCollege == this.openCollege &&
          other.credits == this.credits &&
          other.courseNature == this.courseNature &&
          other.courseCategory == this.courseCategory &&
          other.openType == this.openType &&
          other.teachingClassCount == this.teachingClassCount &&
          other.teacherSummary == this.teacherSummary &&
          other.weekdaySummary == this.weekdaySummary &&
          other.searchText == this.searchText);
}

class CourseTermCourseRowsCompanion
    extends UpdateCompanion<CourseTermCourseRow> {
  final Value<String> id;
  final Value<String> termKey;
  final Value<String> catalogId;
  final Value<String> courseNo;
  final Value<String> courseName;
  final Value<String> openCollege;
  final Value<double?> credits;
  final Value<String> courseNature;
  final Value<String> courseCategory;
  final Value<String> openType;
  final Value<int> teachingClassCount;
  final Value<String> teacherSummary;
  final Value<String> weekdaySummary;
  final Value<String> searchText;
  final Value<int> rowid;
  const CourseTermCourseRowsCompanion({
    this.id = const Value.absent(),
    this.termKey = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.courseNo = const Value.absent(),
    this.courseName = const Value.absent(),
    this.openCollege = const Value.absent(),
    this.credits = const Value.absent(),
    this.courseNature = const Value.absent(),
    this.courseCategory = const Value.absent(),
    this.openType = const Value.absent(),
    this.teachingClassCount = const Value.absent(),
    this.teacherSummary = const Value.absent(),
    this.weekdaySummary = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseTermCourseRowsCompanion.insert({
    required String id,
    required String termKey,
    required String catalogId,
    required String courseNo,
    required String courseName,
    this.openCollege = const Value.absent(),
    this.credits = const Value.absent(),
    this.courseNature = const Value.absent(),
    this.courseCategory = const Value.absent(),
    this.openType = const Value.absent(),
    this.teachingClassCount = const Value.absent(),
    this.teacherSummary = const Value.absent(),
    this.weekdaySummary = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       termKey = Value(termKey),
       catalogId = Value(catalogId),
       courseNo = Value(courseNo),
       courseName = Value(courseName);
  static Insertable<CourseTermCourseRow> custom({
    Expression<String>? id,
    Expression<String>? termKey,
    Expression<String>? catalogId,
    Expression<String>? courseNo,
    Expression<String>? courseName,
    Expression<String>? openCollege,
    Expression<double>? credits,
    Expression<String>? courseNature,
    Expression<String>? courseCategory,
    Expression<String>? openType,
    Expression<int>? teachingClassCount,
    Expression<String>? teacherSummary,
    Expression<String>? weekdaySummary,
    Expression<String>? searchText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (termKey != null) 'term_key': termKey,
      if (catalogId != null) 'catalog_id': catalogId,
      if (courseNo != null) 'course_no': courseNo,
      if (courseName != null) 'course_name': courseName,
      if (openCollege != null) 'open_college': openCollege,
      if (credits != null) 'credits': credits,
      if (courseNature != null) 'course_nature': courseNature,
      if (courseCategory != null) 'course_category': courseCategory,
      if (openType != null) 'open_type': openType,
      if (teachingClassCount != null)
        'teaching_class_count': teachingClassCount,
      if (teacherSummary != null) 'teacher_summary': teacherSummary,
      if (weekdaySummary != null) 'weekday_summary': weekdaySummary,
      if (searchText != null) 'search_text': searchText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseTermCourseRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? termKey,
    Value<String>? catalogId,
    Value<String>? courseNo,
    Value<String>? courseName,
    Value<String>? openCollege,
    Value<double?>? credits,
    Value<String>? courseNature,
    Value<String>? courseCategory,
    Value<String>? openType,
    Value<int>? teachingClassCount,
    Value<String>? teacherSummary,
    Value<String>? weekdaySummary,
    Value<String>? searchText,
    Value<int>? rowid,
  }) {
    return CourseTermCourseRowsCompanion(
      id: id ?? this.id,
      termKey: termKey ?? this.termKey,
      catalogId: catalogId ?? this.catalogId,
      courseNo: courseNo ?? this.courseNo,
      courseName: courseName ?? this.courseName,
      openCollege: openCollege ?? this.openCollege,
      credits: credits ?? this.credits,
      courseNature: courseNature ?? this.courseNature,
      courseCategory: courseCategory ?? this.courseCategory,
      openType: openType ?? this.openType,
      teachingClassCount: teachingClassCount ?? this.teachingClassCount,
      teacherSummary: teacherSummary ?? this.teacherSummary,
      weekdaySummary: weekdaySummary ?? this.weekdaySummary,
      searchText: searchText ?? this.searchText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (termKey.present) {
      map['term_key'] = Variable<String>(termKey.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (courseNo.present) {
      map['course_no'] = Variable<String>(courseNo.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (openCollege.present) {
      map['open_college'] = Variable<String>(openCollege.value);
    }
    if (credits.present) {
      map['credits'] = Variable<double>(credits.value);
    }
    if (courseNature.present) {
      map['course_nature'] = Variable<String>(courseNature.value);
    }
    if (courseCategory.present) {
      map['course_category'] = Variable<String>(courseCategory.value);
    }
    if (openType.present) {
      map['open_type'] = Variable<String>(openType.value);
    }
    if (teachingClassCount.present) {
      map['teaching_class_count'] = Variable<int>(teachingClassCount.value);
    }
    if (teacherSummary.present) {
      map['teacher_summary'] = Variable<String>(teacherSummary.value);
    }
    if (weekdaySummary.present) {
      map['weekday_summary'] = Variable<String>(weekdaySummary.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseTermCourseRowsCompanion(')
          ..write('id: $id, ')
          ..write('termKey: $termKey, ')
          ..write('catalogId: $catalogId, ')
          ..write('courseNo: $courseNo, ')
          ..write('courseName: $courseName, ')
          ..write('openCollege: $openCollege, ')
          ..write('credits: $credits, ')
          ..write('courseNature: $courseNature, ')
          ..write('courseCategory: $courseCategory, ')
          ..write('openType: $openType, ')
          ..write('teachingClassCount: $teachingClassCount, ')
          ..write('teacherSummary: $teacherSummary, ')
          ..write('weekdaySummary: $weekdaySummary, ')
          ..write('searchText: $searchText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseInstructorCourseRowsTable extends CourseInstructorCourseRows
    with
        TableInfo<$CourseInstructorCourseRowsTable, CourseInstructorCourseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseInstructorCourseRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_catalog_rows (id)',
    ),
  );
  static const VerificationMeta _courseNoMeta = const VerificationMeta(
    'courseNo',
  );
  @override
  late final GeneratedColumn<String> courseNo = GeneratedColumn<String>(
    'course_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  @override
  late final GeneratedColumn<double> credits = GeneratedColumn<double>(
    'credits',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instructorNameMeta = const VerificationMeta(
    'instructorName',
  );
  @override
  late final GeneratedColumn<String> instructorName = GeneratedColumn<String>(
    'instructor_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _instructorNameKeyMeta = const VerificationMeta(
    'instructorNameKey',
  );
  @override
  late final GeneratedColumn<String> instructorNameKey =
      GeneratedColumn<String>(
        'instructor_name_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _offeringCountMeta = const VerificationMeta(
    'offeringCount',
  );
  @override
  late final GeneratedColumn<int> offeringCount = GeneratedColumn<int>(
    'offering_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _latestTermKeyMeta = const VerificationMeta(
    'latestTermKey',
  );
  @override
  late final GeneratedColumn<String> latestTermKey = GeneratedColumn<String>(
    'latest_term_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latestOpenCollegeMeta = const VerificationMeta(
    'latestOpenCollege',
  );
  @override
  late final GeneratedColumn<String> latestOpenCollege =
      GeneratedColumn<String>(
        'latest_open_college',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _latestTeachingTitleMeta =
      const VerificationMeta('latestTeachingTitle');
  @override
  late final GeneratedColumn<String> latestTeachingTitle =
      GeneratedColumn<String>(
        'latest_teaching_title',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catalogId,
    courseNo,
    courseName,
    credits,
    instructorName,
    instructorNameKey,
    offeringCount,
    latestTermKey,
    latestOpenCollege,
    latestTeachingTitle,
    searchText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_instructor_course_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseInstructorCourseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('course_no')) {
      context.handle(
        _courseNoMeta,
        courseNo.isAcceptableOrUnknown(data['course_no']!, _courseNoMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNoMeta);
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNameMeta);
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    }
    if (data.containsKey('instructor_name')) {
      context.handle(
        _instructorNameMeta,
        instructorName.isAcceptableOrUnknown(
          data['instructor_name']!,
          _instructorNameMeta,
        ),
      );
    }
    if (data.containsKey('instructor_name_key')) {
      context.handle(
        _instructorNameKeyMeta,
        instructorNameKey.isAcceptableOrUnknown(
          data['instructor_name_key']!,
          _instructorNameKeyMeta,
        ),
      );
    }
    if (data.containsKey('offering_count')) {
      context.handle(
        _offeringCountMeta,
        offeringCount.isAcceptableOrUnknown(
          data['offering_count']!,
          _offeringCountMeta,
        ),
      );
    }
    if (data.containsKey('latest_term_key')) {
      context.handle(
        _latestTermKeyMeta,
        latestTermKey.isAcceptableOrUnknown(
          data['latest_term_key']!,
          _latestTermKeyMeta,
        ),
      );
    }
    if (data.containsKey('latest_open_college')) {
      context.handle(
        _latestOpenCollegeMeta,
        latestOpenCollege.isAcceptableOrUnknown(
          data['latest_open_college']!,
          _latestOpenCollegeMeta,
        ),
      );
    }
    if (data.containsKey('latest_teaching_title')) {
      context.handle(
        _latestTeachingTitleMeta,
        latestTeachingTitle.isAcceptableOrUnknown(
          data['latest_teaching_title']!,
          _latestTeachingTitleMeta,
        ),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseInstructorCourseRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseInstructorCourseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      courseNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_no'],
      )!,
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credits'],
      ),
      instructorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructor_name'],
      )!,
      instructorNameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructor_name_key'],
      )!,
      offeringCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offering_count'],
      )!,
      latestTermKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_term_key'],
      )!,
      latestOpenCollege: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_open_college'],
      )!,
      latestTeachingTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_teaching_title'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
    );
  }

  @override
  $CourseInstructorCourseRowsTable createAlias(String alias) {
    return $CourseInstructorCourseRowsTable(attachedDatabase, alias);
  }
}

class CourseInstructorCourseRow extends DataClass
    implements Insertable<CourseInstructorCourseRow> {
  final String id;
  final String catalogId;
  final String courseNo;
  final String courseName;
  final double? credits;
  final String instructorName;
  final String instructorNameKey;
  final int offeringCount;
  final String latestTermKey;
  final String latestOpenCollege;
  final String latestTeachingTitle;
  final String searchText;
  const CourseInstructorCourseRow({
    required this.id,
    required this.catalogId,
    required this.courseNo,
    required this.courseName,
    this.credits,
    required this.instructorName,
    required this.instructorNameKey,
    required this.offeringCount,
    required this.latestTermKey,
    required this.latestOpenCollege,
    required this.latestTeachingTitle,
    required this.searchText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['catalog_id'] = Variable<String>(catalogId);
    map['course_no'] = Variable<String>(courseNo);
    map['course_name'] = Variable<String>(courseName);
    if (!nullToAbsent || credits != null) {
      map['credits'] = Variable<double>(credits);
    }
    map['instructor_name'] = Variable<String>(instructorName);
    map['instructor_name_key'] = Variable<String>(instructorNameKey);
    map['offering_count'] = Variable<int>(offeringCount);
    map['latest_term_key'] = Variable<String>(latestTermKey);
    map['latest_open_college'] = Variable<String>(latestOpenCollege);
    map['latest_teaching_title'] = Variable<String>(latestTeachingTitle);
    map['search_text'] = Variable<String>(searchText);
    return map;
  }

  CourseInstructorCourseRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseInstructorCourseRowsCompanion(
      id: Value(id),
      catalogId: Value(catalogId),
      courseNo: Value(courseNo),
      courseName: Value(courseName),
      credits: credits == null && nullToAbsent
          ? const Value.absent()
          : Value(credits),
      instructorName: Value(instructorName),
      instructorNameKey: Value(instructorNameKey),
      offeringCount: Value(offeringCount),
      latestTermKey: Value(latestTermKey),
      latestOpenCollege: Value(latestOpenCollege),
      latestTeachingTitle: Value(latestTeachingTitle),
      searchText: Value(searchText),
    );
  }

  factory CourseInstructorCourseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseInstructorCourseRow(
      id: serializer.fromJson<String>(json['id']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      courseNo: serializer.fromJson<String>(json['courseNo']),
      courseName: serializer.fromJson<String>(json['courseName']),
      credits: serializer.fromJson<double?>(json['credits']),
      instructorName: serializer.fromJson<String>(json['instructorName']),
      instructorNameKey: serializer.fromJson<String>(json['instructorNameKey']),
      offeringCount: serializer.fromJson<int>(json['offeringCount']),
      latestTermKey: serializer.fromJson<String>(json['latestTermKey']),
      latestOpenCollege: serializer.fromJson<String>(json['latestOpenCollege']),
      latestTeachingTitle: serializer.fromJson<String>(
        json['latestTeachingTitle'],
      ),
      searchText: serializer.fromJson<String>(json['searchText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'catalogId': serializer.toJson<String>(catalogId),
      'courseNo': serializer.toJson<String>(courseNo),
      'courseName': serializer.toJson<String>(courseName),
      'credits': serializer.toJson<double?>(credits),
      'instructorName': serializer.toJson<String>(instructorName),
      'instructorNameKey': serializer.toJson<String>(instructorNameKey),
      'offeringCount': serializer.toJson<int>(offeringCount),
      'latestTermKey': serializer.toJson<String>(latestTermKey),
      'latestOpenCollege': serializer.toJson<String>(latestOpenCollege),
      'latestTeachingTitle': serializer.toJson<String>(latestTeachingTitle),
      'searchText': serializer.toJson<String>(searchText),
    };
  }

  CourseInstructorCourseRow copyWith({
    String? id,
    String? catalogId,
    String? courseNo,
    String? courseName,
    Value<double?> credits = const Value.absent(),
    String? instructorName,
    String? instructorNameKey,
    int? offeringCount,
    String? latestTermKey,
    String? latestOpenCollege,
    String? latestTeachingTitle,
    String? searchText,
  }) => CourseInstructorCourseRow(
    id: id ?? this.id,
    catalogId: catalogId ?? this.catalogId,
    courseNo: courseNo ?? this.courseNo,
    courseName: courseName ?? this.courseName,
    credits: credits.present ? credits.value : this.credits,
    instructorName: instructorName ?? this.instructorName,
    instructorNameKey: instructorNameKey ?? this.instructorNameKey,
    offeringCount: offeringCount ?? this.offeringCount,
    latestTermKey: latestTermKey ?? this.latestTermKey,
    latestOpenCollege: latestOpenCollege ?? this.latestOpenCollege,
    latestTeachingTitle: latestTeachingTitle ?? this.latestTeachingTitle,
    searchText: searchText ?? this.searchText,
  );
  CourseInstructorCourseRow copyWithCompanion(
    CourseInstructorCourseRowsCompanion data,
  ) {
    return CourseInstructorCourseRow(
      id: data.id.present ? data.id.value : this.id,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      courseNo: data.courseNo.present ? data.courseNo.value : this.courseNo,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      credits: data.credits.present ? data.credits.value : this.credits,
      instructorName: data.instructorName.present
          ? data.instructorName.value
          : this.instructorName,
      instructorNameKey: data.instructorNameKey.present
          ? data.instructorNameKey.value
          : this.instructorNameKey,
      offeringCount: data.offeringCount.present
          ? data.offeringCount.value
          : this.offeringCount,
      latestTermKey: data.latestTermKey.present
          ? data.latestTermKey.value
          : this.latestTermKey,
      latestOpenCollege: data.latestOpenCollege.present
          ? data.latestOpenCollege.value
          : this.latestOpenCollege,
      latestTeachingTitle: data.latestTeachingTitle.present
          ? data.latestTeachingTitle.value
          : this.latestTeachingTitle,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseInstructorCourseRow(')
          ..write('id: $id, ')
          ..write('catalogId: $catalogId, ')
          ..write('courseNo: $courseNo, ')
          ..write('courseName: $courseName, ')
          ..write('credits: $credits, ')
          ..write('instructorName: $instructorName, ')
          ..write('instructorNameKey: $instructorNameKey, ')
          ..write('offeringCount: $offeringCount, ')
          ..write('latestTermKey: $latestTermKey, ')
          ..write('latestOpenCollege: $latestOpenCollege, ')
          ..write('latestTeachingTitle: $latestTeachingTitle, ')
          ..write('searchText: $searchText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    catalogId,
    courseNo,
    courseName,
    credits,
    instructorName,
    instructorNameKey,
    offeringCount,
    latestTermKey,
    latestOpenCollege,
    latestTeachingTitle,
    searchText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseInstructorCourseRow &&
          other.id == this.id &&
          other.catalogId == this.catalogId &&
          other.courseNo == this.courseNo &&
          other.courseName == this.courseName &&
          other.credits == this.credits &&
          other.instructorName == this.instructorName &&
          other.instructorNameKey == this.instructorNameKey &&
          other.offeringCount == this.offeringCount &&
          other.latestTermKey == this.latestTermKey &&
          other.latestOpenCollege == this.latestOpenCollege &&
          other.latestTeachingTitle == this.latestTeachingTitle &&
          other.searchText == this.searchText);
}

class CourseInstructorCourseRowsCompanion
    extends UpdateCompanion<CourseInstructorCourseRow> {
  final Value<String> id;
  final Value<String> catalogId;
  final Value<String> courseNo;
  final Value<String> courseName;
  final Value<double?> credits;
  final Value<String> instructorName;
  final Value<String> instructorNameKey;
  final Value<int> offeringCount;
  final Value<String> latestTermKey;
  final Value<String> latestOpenCollege;
  final Value<String> latestTeachingTitle;
  final Value<String> searchText;
  final Value<int> rowid;
  const CourseInstructorCourseRowsCompanion({
    this.id = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.courseNo = const Value.absent(),
    this.courseName = const Value.absent(),
    this.credits = const Value.absent(),
    this.instructorName = const Value.absent(),
    this.instructorNameKey = const Value.absent(),
    this.offeringCount = const Value.absent(),
    this.latestTermKey = const Value.absent(),
    this.latestOpenCollege = const Value.absent(),
    this.latestTeachingTitle = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseInstructorCourseRowsCompanion.insert({
    required String id,
    required String catalogId,
    required String courseNo,
    required String courseName,
    this.credits = const Value.absent(),
    this.instructorName = const Value.absent(),
    this.instructorNameKey = const Value.absent(),
    this.offeringCount = const Value.absent(),
    this.latestTermKey = const Value.absent(),
    this.latestOpenCollege = const Value.absent(),
    this.latestTeachingTitle = const Value.absent(),
    this.searchText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       catalogId = Value(catalogId),
       courseNo = Value(courseNo),
       courseName = Value(courseName);
  static Insertable<CourseInstructorCourseRow> custom({
    Expression<String>? id,
    Expression<String>? catalogId,
    Expression<String>? courseNo,
    Expression<String>? courseName,
    Expression<double>? credits,
    Expression<String>? instructorName,
    Expression<String>? instructorNameKey,
    Expression<int>? offeringCount,
    Expression<String>? latestTermKey,
    Expression<String>? latestOpenCollege,
    Expression<String>? latestTeachingTitle,
    Expression<String>? searchText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catalogId != null) 'catalog_id': catalogId,
      if (courseNo != null) 'course_no': courseNo,
      if (courseName != null) 'course_name': courseName,
      if (credits != null) 'credits': credits,
      if (instructorName != null) 'instructor_name': instructorName,
      if (instructorNameKey != null) 'instructor_name_key': instructorNameKey,
      if (offeringCount != null) 'offering_count': offeringCount,
      if (latestTermKey != null) 'latest_term_key': latestTermKey,
      if (latestOpenCollege != null) 'latest_open_college': latestOpenCollege,
      if (latestTeachingTitle != null)
        'latest_teaching_title': latestTeachingTitle,
      if (searchText != null) 'search_text': searchText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseInstructorCourseRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? catalogId,
    Value<String>? courseNo,
    Value<String>? courseName,
    Value<double?>? credits,
    Value<String>? instructorName,
    Value<String>? instructorNameKey,
    Value<int>? offeringCount,
    Value<String>? latestTermKey,
    Value<String>? latestOpenCollege,
    Value<String>? latestTeachingTitle,
    Value<String>? searchText,
    Value<int>? rowid,
  }) {
    return CourseInstructorCourseRowsCompanion(
      id: id ?? this.id,
      catalogId: catalogId ?? this.catalogId,
      courseNo: courseNo ?? this.courseNo,
      courseName: courseName ?? this.courseName,
      credits: credits ?? this.credits,
      instructorName: instructorName ?? this.instructorName,
      instructorNameKey: instructorNameKey ?? this.instructorNameKey,
      offeringCount: offeringCount ?? this.offeringCount,
      latestTermKey: latestTermKey ?? this.latestTermKey,
      latestOpenCollege: latestOpenCollege ?? this.latestOpenCollege,
      latestTeachingTitle: latestTeachingTitle ?? this.latestTeachingTitle,
      searchText: searchText ?? this.searchText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (courseNo.present) {
      map['course_no'] = Variable<String>(courseNo.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (credits.present) {
      map['credits'] = Variable<double>(credits.value);
    }
    if (instructorName.present) {
      map['instructor_name'] = Variable<String>(instructorName.value);
    }
    if (instructorNameKey.present) {
      map['instructor_name_key'] = Variable<String>(instructorNameKey.value);
    }
    if (offeringCount.present) {
      map['offering_count'] = Variable<int>(offeringCount.value);
    }
    if (latestTermKey.present) {
      map['latest_term_key'] = Variable<String>(latestTermKey.value);
    }
    if (latestOpenCollege.present) {
      map['latest_open_college'] = Variable<String>(latestOpenCollege.value);
    }
    if (latestTeachingTitle.present) {
      map['latest_teaching_title'] = Variable<String>(
        latestTeachingTitle.value,
      );
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseInstructorCourseRowsCompanion(')
          ..write('id: $id, ')
          ..write('catalogId: $catalogId, ')
          ..write('courseNo: $courseNo, ')
          ..write('courseName: $courseName, ')
          ..write('credits: $credits, ')
          ..write('instructorName: $instructorName, ')
          ..write('instructorNameKey: $instructorNameKey, ')
          ..write('offeringCount: $offeringCount, ')
          ..write('latestTermKey: $latestTermKey, ')
          ..write('latestOpenCollege: $latestOpenCollege, ')
          ..write('latestTeachingTitle: $latestTeachingTitle, ')
          ..write('searchText: $searchText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseOfferingRowsTable extends CourseOfferingRows
    with TableInfo<$CourseOfferingRowsTable, CourseOfferingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseOfferingRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termKeyMeta = const VerificationMeta(
    'termKey',
  );
  @override
  late final GeneratedColumn<String> termKey = GeneratedColumn<String>(
    'term_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES school_timetable_term_rows (term_key)',
    ),
  );
  static const VerificationMeta _termCourseIdMeta = const VerificationMeta(
    'termCourseId',
  );
  @override
  late final GeneratedColumn<String> termCourseId = GeneratedColumn<String>(
    'term_course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_term_course_rows (id)',
    ),
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_catalog_rows (id)',
    ),
  );
  static const VerificationMeta _instructorCourseIdMeta =
      const VerificationMeta('instructorCourseId');
  @override
  late final GeneratedColumn<String> instructorCourseId =
      GeneratedColumn<String>(
        'instructor_course_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES course_instructor_course_rows (id)',
        ),
      );
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  @override
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageIndexMeta = const VerificationMeta(
    'packageIndex',
  );
  @override
  late final GeneratedColumn<int> packageIndex = GeneratedColumn<int>(
    'package_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceStatusMeta = const VerificationMeta(
    'sourceStatus',
  );
  @override
  late final GeneratedColumn<String> sourceStatus = GeneratedColumn<String>(
    'source_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _schoolYearMeta = const VerificationMeta(
    'schoolYear',
  );
  @override
  late final GeneratedColumn<String> schoolYear = GeneratedColumn<String>(
    'school_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teachingClassNameMeta = const VerificationMeta(
    'teachingClassName',
  );
  @override
  late final GeneratedColumn<String> teachingClassName =
      GeneratedColumn<String>(
        'teaching_class_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _courseNoMeta = const VerificationMeta(
    'courseNo',
  );
  @override
  late final GeneratedColumn<String> courseNo = GeneratedColumn<String>(
    'course_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openCollegeMeta = const VerificationMeta(
    'openCollege',
  );
  @override
  late final GeneratedColumn<String> openCollege = GeneratedColumn<String>(
    'open_college',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _planCollegeMeta = const VerificationMeta(
    'planCollege',
  );
  @override
  late final GeneratedColumn<String> planCollege = GeneratedColumn<String>(
    'plan_college',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  @override
  late final GeneratedColumn<double> credits = GeneratedColumn<double>(
    'credits',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseNatureMeta = const VerificationMeta(
    'courseNature',
  );
  @override
  late final GeneratedColumn<String> courseNature = GeneratedColumn<String>(
    'course_nature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseCategoryMeta = const VerificationMeta(
    'courseCategory',
  );
  @override
  late final GeneratedColumn<String> courseCategory = GeneratedColumn<String>(
    'course_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _openTypeMeta = const VerificationMeta(
    'openType',
  );
  @override
  late final GeneratedColumn<String> openType = GeneratedColumn<String>(
    'open_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _majorMeta = const VerificationMeta('major');
  @override
  late final GeneratedColumn<String> major = GeneratedColumn<String>(
    'major',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _instructorMeta = const VerificationMeta(
    'instructor',
  );
  @override
  late final GeneratedColumn<String> instructor = GeneratedColumn<String>(
    'instructor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _peopleRawMeta = const VerificationMeta(
    'peopleRaw',
  );
  @override
  late final GeneratedColumn<String> peopleRaw = GeneratedColumn<String>(
    'people_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _theoryHoursMeta = const VerificationMeta(
    'theoryHours',
  );
  @override
  late final GeneratedColumn<int> theoryHours = GeneratedColumn<int>(
    'theory_hours',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _computerHoursMeta = const VerificationMeta(
    'computerHours',
  );
  @override
  late final GeneratedColumn<int> computerHours = GeneratedColumn<int>(
    'computer_hours',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _experimentHoursMeta = const VerificationMeta(
    'experimentHours',
  );
  @override
  late final GeneratedColumn<int> experimentHours = GeneratedColumn<int>(
    'experiment_hours',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _practiceHoursMeta = const VerificationMeta(
    'practiceHours',
  );
  @override
  late final GeneratedColumn<int> practiceHours = GeneratedColumn<int>(
    'practice_hours',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sundayRawMeta = const VerificationMeta(
    'sundayRaw',
  );
  @override
  late final GeneratedColumn<String> sundayRaw = GeneratedColumn<String>(
    'sunday_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mondayRawMeta = const VerificationMeta(
    'mondayRaw',
  );
  @override
  late final GeneratedColumn<String> mondayRaw = GeneratedColumn<String>(
    'monday_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tuesdayRawMeta = const VerificationMeta(
    'tuesdayRaw',
  );
  @override
  late final GeneratedColumn<String> tuesdayRaw = GeneratedColumn<String>(
    'tuesday_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _wednesdayRawMeta = const VerificationMeta(
    'wednesdayRaw',
  );
  @override
  late final GeneratedColumn<String> wednesdayRaw = GeneratedColumn<String>(
    'wednesday_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _thursdayRawMeta = const VerificationMeta(
    'thursdayRaw',
  );
  @override
  late final GeneratedColumn<String> thursdayRaw = GeneratedColumn<String>(
    'thursday_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fridayRawMeta = const VerificationMeta(
    'fridayRaw',
  );
  @override
  late final GeneratedColumn<String> fridayRaw = GeneratedColumn<String>(
    'friday_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _saturdayRawMeta = const VerificationMeta(
    'saturdayRaw',
  );
  @override
  late final GeneratedColumn<String> saturdayRaw = GeneratedColumn<String>(
    'saturday_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _otherTeachersMeta = const VerificationMeta(
    'otherTeachers',
  );
  @override
  late final GeneratedColumn<String> otherTeachers = GeneratedColumn<String>(
    'other_teachers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _textbookMeta = const VerificationMeta(
    'textbook',
  );
  @override
  late final GeneratedColumn<String> textbook = GeneratedColumn<String>(
    'textbook',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _openDepartmentCodeMeta =
      const VerificationMeta('openDepartmentCode');
  @override
  late final GeneratedColumn<String> openDepartmentCode =
      GeneratedColumn<String>(
        'open_department_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _collegeCodeMeta = const VerificationMeta(
    'collegeCode',
  );
  @override
  late final GeneratedColumn<String> collegeCode = GeneratedColumn<String>(
    'college_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _majorCodeMeta = const VerificationMeta(
    'majorCode',
  );
  @override
  late final GeneratedColumn<String> majorCode = GeneratedColumn<String>(
    'major_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _gradeCodeMeta = const VerificationMeta(
    'gradeCode',
  );
  @override
  late final GeneratedColumn<String> gradeCode = GeneratedColumn<String>(
    'grade_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _schoolYearCodeMeta = const VerificationMeta(
    'schoolYearCode',
  );
  @override
  late final GeneratedColumn<String> schoolYearCode = GeneratedColumn<String>(
    'school_year_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _termCodeMeta = const VerificationMeta(
    'termCode',
  );
  @override
  late final GeneratedColumn<String> termCode = GeneratedColumn<String>(
    'term_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseCategoryCodeMeta =
      const VerificationMeta('courseCategoryCode');
  @override
  late final GeneratedColumn<String> courseCategoryCode =
      GeneratedColumn<String>(
        'course_category_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _conditionCodeMeta = const VerificationMeta(
    'conditionCode',
  );
  @override
  late final GeneratedColumn<String> conditionCode = GeneratedColumn<String>(
    'condition_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _openTypeCodeMeta = const VerificationMeta(
    'openTypeCode',
  );
  @override
  late final GeneratedColumn<String> openTypeCode = GeneratedColumn<String>(
    'open_type_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseNatureCodeMeta = const VerificationMeta(
    'courseNatureCode',
  );
  @override
  late final GeneratedColumn<String> courseNatureCode = GeneratedColumn<String>(
    'course_nature_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _scheduleSummaryMeta = const VerificationMeta(
    'scheduleSummary',
  );
  @override
  late final GeneratedColumn<String> scheduleSummary = GeneratedColumn<String>(
    'schedule_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _weekdaySummaryMeta = const VerificationMeta(
    'weekdaySummary',
  );
  @override
  late final GeneratedColumn<String> weekdaySummary = GeneratedColumn<String>(
    'weekday_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _originalFieldsJsonMeta =
      const VerificationMeta('originalFieldsJson');
  @override
  late final GeneratedColumn<String> originalFieldsJson =
      GeneratedColumn<String>(
        'original_fields_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    termKey,
    termCourseId,
    catalogId,
    instructorCourseId,
    sourceKey,
    packageIndex,
    sourceStatus,
    schoolYear,
    term,
    teachingClassName,
    courseNo,
    courseName,
    openCollege,
    planCollege,
    credits,
    courseNature,
    courseCategory,
    openType,
    grade,
    major,
    instructor,
    title,
    peopleRaw,
    theoryHours,
    computerHours,
    experimentHours,
    practiceHours,
    sundayRaw,
    mondayRaw,
    tuesdayRaw,
    wednesdayRaw,
    thursdayRaw,
    fridayRaw,
    saturdayRaw,
    remark,
    otherTeachers,
    textbook,
    publisher,
    openDepartmentCode,
    collegeCode,
    majorCode,
    gradeCode,
    schoolYearCode,
    termCode,
    courseCategoryCode,
    conditionCode,
    openTypeCode,
    courseNatureCode,
    note,
    scheduleSummary,
    weekdaySummary,
    searchText,
    originalFieldsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_offering_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseOfferingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('term_key')) {
      context.handle(
        _termKeyMeta,
        termKey.isAcceptableOrUnknown(data['term_key']!, _termKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_termKeyMeta);
    }
    if (data.containsKey('term_course_id')) {
      context.handle(
        _termCourseIdMeta,
        termCourseId.isAcceptableOrUnknown(
          data['term_course_id']!,
          _termCourseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_termCourseIdMeta);
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('instructor_course_id')) {
      context.handle(
        _instructorCourseIdMeta,
        instructorCourseId.isAcceptableOrUnknown(
          data['instructor_course_id']!,
          _instructorCourseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructorCourseIdMeta);
    }
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKeyMeta);
    }
    if (data.containsKey('package_index')) {
      context.handle(
        _packageIndexMeta,
        packageIndex.isAcceptableOrUnknown(
          data['package_index']!,
          _packageIndexMeta,
        ),
      );
    }
    if (data.containsKey('source_status')) {
      context.handle(
        _sourceStatusMeta,
        sourceStatus.isAcceptableOrUnknown(
          data['source_status']!,
          _sourceStatusMeta,
        ),
      );
    }
    if (data.containsKey('school_year')) {
      context.handle(
        _schoolYearMeta,
        schoolYear.isAcceptableOrUnknown(data['school_year']!, _schoolYearMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolYearMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('teaching_class_name')) {
      context.handle(
        _teachingClassNameMeta,
        teachingClassName.isAcceptableOrUnknown(
          data['teaching_class_name']!,
          _teachingClassNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_teachingClassNameMeta);
    }
    if (data.containsKey('course_no')) {
      context.handle(
        _courseNoMeta,
        courseNo.isAcceptableOrUnknown(data['course_no']!, _courseNoMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNoMeta);
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNameMeta);
    }
    if (data.containsKey('open_college')) {
      context.handle(
        _openCollegeMeta,
        openCollege.isAcceptableOrUnknown(
          data['open_college']!,
          _openCollegeMeta,
        ),
      );
    }
    if (data.containsKey('plan_college')) {
      context.handle(
        _planCollegeMeta,
        planCollege.isAcceptableOrUnknown(
          data['plan_college']!,
          _planCollegeMeta,
        ),
      );
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    }
    if (data.containsKey('course_nature')) {
      context.handle(
        _courseNatureMeta,
        courseNature.isAcceptableOrUnknown(
          data['course_nature']!,
          _courseNatureMeta,
        ),
      );
    }
    if (data.containsKey('course_category')) {
      context.handle(
        _courseCategoryMeta,
        courseCategory.isAcceptableOrUnknown(
          data['course_category']!,
          _courseCategoryMeta,
        ),
      );
    }
    if (data.containsKey('open_type')) {
      context.handle(
        _openTypeMeta,
        openType.isAcceptableOrUnknown(data['open_type']!, _openTypeMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('major')) {
      context.handle(
        _majorMeta,
        major.isAcceptableOrUnknown(data['major']!, _majorMeta),
      );
    }
    if (data.containsKey('instructor')) {
      context.handle(
        _instructorMeta,
        instructor.isAcceptableOrUnknown(data['instructor']!, _instructorMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('people_raw')) {
      context.handle(
        _peopleRawMeta,
        peopleRaw.isAcceptableOrUnknown(data['people_raw']!, _peopleRawMeta),
      );
    }
    if (data.containsKey('theory_hours')) {
      context.handle(
        _theoryHoursMeta,
        theoryHours.isAcceptableOrUnknown(
          data['theory_hours']!,
          _theoryHoursMeta,
        ),
      );
    }
    if (data.containsKey('computer_hours')) {
      context.handle(
        _computerHoursMeta,
        computerHours.isAcceptableOrUnknown(
          data['computer_hours']!,
          _computerHoursMeta,
        ),
      );
    }
    if (data.containsKey('experiment_hours')) {
      context.handle(
        _experimentHoursMeta,
        experimentHours.isAcceptableOrUnknown(
          data['experiment_hours']!,
          _experimentHoursMeta,
        ),
      );
    }
    if (data.containsKey('practice_hours')) {
      context.handle(
        _practiceHoursMeta,
        practiceHours.isAcceptableOrUnknown(
          data['practice_hours']!,
          _practiceHoursMeta,
        ),
      );
    }
    if (data.containsKey('sunday_raw')) {
      context.handle(
        _sundayRawMeta,
        sundayRaw.isAcceptableOrUnknown(data['sunday_raw']!, _sundayRawMeta),
      );
    }
    if (data.containsKey('monday_raw')) {
      context.handle(
        _mondayRawMeta,
        mondayRaw.isAcceptableOrUnknown(data['monday_raw']!, _mondayRawMeta),
      );
    }
    if (data.containsKey('tuesday_raw')) {
      context.handle(
        _tuesdayRawMeta,
        tuesdayRaw.isAcceptableOrUnknown(data['tuesday_raw']!, _tuesdayRawMeta),
      );
    }
    if (data.containsKey('wednesday_raw')) {
      context.handle(
        _wednesdayRawMeta,
        wednesdayRaw.isAcceptableOrUnknown(
          data['wednesday_raw']!,
          _wednesdayRawMeta,
        ),
      );
    }
    if (data.containsKey('thursday_raw')) {
      context.handle(
        _thursdayRawMeta,
        thursdayRaw.isAcceptableOrUnknown(
          data['thursday_raw']!,
          _thursdayRawMeta,
        ),
      );
    }
    if (data.containsKey('friday_raw')) {
      context.handle(
        _fridayRawMeta,
        fridayRaw.isAcceptableOrUnknown(data['friday_raw']!, _fridayRawMeta),
      );
    }
    if (data.containsKey('saturday_raw')) {
      context.handle(
        _saturdayRawMeta,
        saturdayRaw.isAcceptableOrUnknown(
          data['saturday_raw']!,
          _saturdayRawMeta,
        ),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    if (data.containsKey('other_teachers')) {
      context.handle(
        _otherTeachersMeta,
        otherTeachers.isAcceptableOrUnknown(
          data['other_teachers']!,
          _otherTeachersMeta,
        ),
      );
    }
    if (data.containsKey('textbook')) {
      context.handle(
        _textbookMeta,
        textbook.isAcceptableOrUnknown(data['textbook']!, _textbookMeta),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('open_department_code')) {
      context.handle(
        _openDepartmentCodeMeta,
        openDepartmentCode.isAcceptableOrUnknown(
          data['open_department_code']!,
          _openDepartmentCodeMeta,
        ),
      );
    }
    if (data.containsKey('college_code')) {
      context.handle(
        _collegeCodeMeta,
        collegeCode.isAcceptableOrUnknown(
          data['college_code']!,
          _collegeCodeMeta,
        ),
      );
    }
    if (data.containsKey('major_code')) {
      context.handle(
        _majorCodeMeta,
        majorCode.isAcceptableOrUnknown(data['major_code']!, _majorCodeMeta),
      );
    }
    if (data.containsKey('grade_code')) {
      context.handle(
        _gradeCodeMeta,
        gradeCode.isAcceptableOrUnknown(data['grade_code']!, _gradeCodeMeta),
      );
    }
    if (data.containsKey('school_year_code')) {
      context.handle(
        _schoolYearCodeMeta,
        schoolYearCode.isAcceptableOrUnknown(
          data['school_year_code']!,
          _schoolYearCodeMeta,
        ),
      );
    }
    if (data.containsKey('term_code')) {
      context.handle(
        _termCodeMeta,
        termCode.isAcceptableOrUnknown(data['term_code']!, _termCodeMeta),
      );
    }
    if (data.containsKey('course_category_code')) {
      context.handle(
        _courseCategoryCodeMeta,
        courseCategoryCode.isAcceptableOrUnknown(
          data['course_category_code']!,
          _courseCategoryCodeMeta,
        ),
      );
    }
    if (data.containsKey('condition_code')) {
      context.handle(
        _conditionCodeMeta,
        conditionCode.isAcceptableOrUnknown(
          data['condition_code']!,
          _conditionCodeMeta,
        ),
      );
    }
    if (data.containsKey('open_type_code')) {
      context.handle(
        _openTypeCodeMeta,
        openTypeCode.isAcceptableOrUnknown(
          data['open_type_code']!,
          _openTypeCodeMeta,
        ),
      );
    }
    if (data.containsKey('course_nature_code')) {
      context.handle(
        _courseNatureCodeMeta,
        courseNatureCode.isAcceptableOrUnknown(
          data['course_nature_code']!,
          _courseNatureCodeMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('schedule_summary')) {
      context.handle(
        _scheduleSummaryMeta,
        scheduleSummary.isAcceptableOrUnknown(
          data['schedule_summary']!,
          _scheduleSummaryMeta,
        ),
      );
    }
    if (data.containsKey('weekday_summary')) {
      context.handle(
        _weekdaySummaryMeta,
        weekdaySummary.isAcceptableOrUnknown(
          data['weekday_summary']!,
          _weekdaySummaryMeta,
        ),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    }
    if (data.containsKey('original_fields_json')) {
      context.handle(
        _originalFieldsJsonMeta,
        originalFieldsJson.isAcceptableOrUnknown(
          data['original_fields_json']!,
          _originalFieldsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseOfferingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseOfferingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      termKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_key'],
      )!,
      termCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_course_id'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      instructorCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructor_course_id'],
      )!,
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      packageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}package_index'],
      )!,
      sourceStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_status'],
      )!,
      schoolYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_year'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      teachingClassName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teaching_class_name'],
      )!,
      courseNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_no'],
      )!,
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      )!,
      openCollege: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_college'],
      )!,
      planCollege: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_college'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credits'],
      ),
      courseNature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_nature'],
      )!,
      courseCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_category'],
      )!,
      openType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_type'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      )!,
      major: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}major'],
      )!,
      instructor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructor'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      peopleRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}people_raw'],
      )!,
      theoryHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}theory_hours'],
      ),
      computerHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}computer_hours'],
      ),
      experimentHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}experiment_hours'],
      ),
      practiceHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}practice_hours'],
      ),
      sundayRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sunday_raw'],
      )!,
      mondayRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monday_raw'],
      )!,
      tuesdayRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tuesday_raw'],
      )!,
      wednesdayRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wednesday_raw'],
      )!,
      thursdayRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thursday_raw'],
      )!,
      fridayRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}friday_raw'],
      )!,
      saturdayRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saturday_raw'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      )!,
      otherTeachers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_teachers'],
      )!,
      textbook: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}textbook'],
      )!,
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      )!,
      openDepartmentCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_department_code'],
      )!,
      collegeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}college_code'],
      )!,
      majorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}major_code'],
      )!,
      gradeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade_code'],
      )!,
      schoolYearCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_year_code'],
      )!,
      termCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_code'],
      )!,
      courseCategoryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_category_code'],
      )!,
      conditionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_code'],
      )!,
      openTypeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_type_code'],
      )!,
      courseNatureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_nature_code'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      scheduleSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_summary'],
      )!,
      weekdaySummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekday_summary'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      originalFieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_fields_json'],
      )!,
    );
  }

  @override
  $CourseOfferingRowsTable createAlias(String alias) {
    return $CourseOfferingRowsTable(attachedDatabase, alias);
  }
}

class CourseOfferingRow extends DataClass
    implements Insertable<CourseOfferingRow> {
  final String id;
  final String termKey;
  final String termCourseId;
  final String catalogId;
  final String instructorCourseId;
  final String sourceKey;
  final int packageIndex;
  final String sourceStatus;
  final String schoolYear;
  final String term;
  final String teachingClassName;
  final String courseNo;
  final String courseName;
  final String openCollege;
  final String planCollege;
  final double? credits;
  final String courseNature;
  final String courseCategory;
  final String openType;
  final String grade;
  final String major;
  final String instructor;
  final String title;
  final String peopleRaw;
  final int? theoryHours;
  final int? computerHours;
  final int? experimentHours;
  final int? practiceHours;
  final String sundayRaw;
  final String mondayRaw;
  final String tuesdayRaw;
  final String wednesdayRaw;
  final String thursdayRaw;
  final String fridayRaw;
  final String saturdayRaw;
  final String remark;
  final String otherTeachers;
  final String textbook;
  final String publisher;
  final String openDepartmentCode;
  final String collegeCode;
  final String majorCode;
  final String gradeCode;
  final String schoolYearCode;
  final String termCode;
  final String courseCategoryCode;
  final String conditionCode;
  final String openTypeCode;
  final String courseNatureCode;
  final String note;
  final String scheduleSummary;
  final String weekdaySummary;
  final String searchText;
  final String originalFieldsJson;
  const CourseOfferingRow({
    required this.id,
    required this.termKey,
    required this.termCourseId,
    required this.catalogId,
    required this.instructorCourseId,
    required this.sourceKey,
    required this.packageIndex,
    required this.sourceStatus,
    required this.schoolYear,
    required this.term,
    required this.teachingClassName,
    required this.courseNo,
    required this.courseName,
    required this.openCollege,
    required this.planCollege,
    this.credits,
    required this.courseNature,
    required this.courseCategory,
    required this.openType,
    required this.grade,
    required this.major,
    required this.instructor,
    required this.title,
    required this.peopleRaw,
    this.theoryHours,
    this.computerHours,
    this.experimentHours,
    this.practiceHours,
    required this.sundayRaw,
    required this.mondayRaw,
    required this.tuesdayRaw,
    required this.wednesdayRaw,
    required this.thursdayRaw,
    required this.fridayRaw,
    required this.saturdayRaw,
    required this.remark,
    required this.otherTeachers,
    required this.textbook,
    required this.publisher,
    required this.openDepartmentCode,
    required this.collegeCode,
    required this.majorCode,
    required this.gradeCode,
    required this.schoolYearCode,
    required this.termCode,
    required this.courseCategoryCode,
    required this.conditionCode,
    required this.openTypeCode,
    required this.courseNatureCode,
    required this.note,
    required this.scheduleSummary,
    required this.weekdaySummary,
    required this.searchText,
    required this.originalFieldsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['term_key'] = Variable<String>(termKey);
    map['term_course_id'] = Variable<String>(termCourseId);
    map['catalog_id'] = Variable<String>(catalogId);
    map['instructor_course_id'] = Variable<String>(instructorCourseId);
    map['source_key'] = Variable<String>(sourceKey);
    map['package_index'] = Variable<int>(packageIndex);
    map['source_status'] = Variable<String>(sourceStatus);
    map['school_year'] = Variable<String>(schoolYear);
    map['term'] = Variable<String>(term);
    map['teaching_class_name'] = Variable<String>(teachingClassName);
    map['course_no'] = Variable<String>(courseNo);
    map['course_name'] = Variable<String>(courseName);
    map['open_college'] = Variable<String>(openCollege);
    map['plan_college'] = Variable<String>(planCollege);
    if (!nullToAbsent || credits != null) {
      map['credits'] = Variable<double>(credits);
    }
    map['course_nature'] = Variable<String>(courseNature);
    map['course_category'] = Variable<String>(courseCategory);
    map['open_type'] = Variable<String>(openType);
    map['grade'] = Variable<String>(grade);
    map['major'] = Variable<String>(major);
    map['instructor'] = Variable<String>(instructor);
    map['title'] = Variable<String>(title);
    map['people_raw'] = Variable<String>(peopleRaw);
    if (!nullToAbsent || theoryHours != null) {
      map['theory_hours'] = Variable<int>(theoryHours);
    }
    if (!nullToAbsent || computerHours != null) {
      map['computer_hours'] = Variable<int>(computerHours);
    }
    if (!nullToAbsent || experimentHours != null) {
      map['experiment_hours'] = Variable<int>(experimentHours);
    }
    if (!nullToAbsent || practiceHours != null) {
      map['practice_hours'] = Variable<int>(practiceHours);
    }
    map['sunday_raw'] = Variable<String>(sundayRaw);
    map['monday_raw'] = Variable<String>(mondayRaw);
    map['tuesday_raw'] = Variable<String>(tuesdayRaw);
    map['wednesday_raw'] = Variable<String>(wednesdayRaw);
    map['thursday_raw'] = Variable<String>(thursdayRaw);
    map['friday_raw'] = Variable<String>(fridayRaw);
    map['saturday_raw'] = Variable<String>(saturdayRaw);
    map['remark'] = Variable<String>(remark);
    map['other_teachers'] = Variable<String>(otherTeachers);
    map['textbook'] = Variable<String>(textbook);
    map['publisher'] = Variable<String>(publisher);
    map['open_department_code'] = Variable<String>(openDepartmentCode);
    map['college_code'] = Variable<String>(collegeCode);
    map['major_code'] = Variable<String>(majorCode);
    map['grade_code'] = Variable<String>(gradeCode);
    map['school_year_code'] = Variable<String>(schoolYearCode);
    map['term_code'] = Variable<String>(termCode);
    map['course_category_code'] = Variable<String>(courseCategoryCode);
    map['condition_code'] = Variable<String>(conditionCode);
    map['open_type_code'] = Variable<String>(openTypeCode);
    map['course_nature_code'] = Variable<String>(courseNatureCode);
    map['note'] = Variable<String>(note);
    map['schedule_summary'] = Variable<String>(scheduleSummary);
    map['weekday_summary'] = Variable<String>(weekdaySummary);
    map['search_text'] = Variable<String>(searchText);
    map['original_fields_json'] = Variable<String>(originalFieldsJson);
    return map;
  }

  CourseOfferingRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseOfferingRowsCompanion(
      id: Value(id),
      termKey: Value(termKey),
      termCourseId: Value(termCourseId),
      catalogId: Value(catalogId),
      instructorCourseId: Value(instructorCourseId),
      sourceKey: Value(sourceKey),
      packageIndex: Value(packageIndex),
      sourceStatus: Value(sourceStatus),
      schoolYear: Value(schoolYear),
      term: Value(term),
      teachingClassName: Value(teachingClassName),
      courseNo: Value(courseNo),
      courseName: Value(courseName),
      openCollege: Value(openCollege),
      planCollege: Value(planCollege),
      credits: credits == null && nullToAbsent
          ? const Value.absent()
          : Value(credits),
      courseNature: Value(courseNature),
      courseCategory: Value(courseCategory),
      openType: Value(openType),
      grade: Value(grade),
      major: Value(major),
      instructor: Value(instructor),
      title: Value(title),
      peopleRaw: Value(peopleRaw),
      theoryHours: theoryHours == null && nullToAbsent
          ? const Value.absent()
          : Value(theoryHours),
      computerHours: computerHours == null && nullToAbsent
          ? const Value.absent()
          : Value(computerHours),
      experimentHours: experimentHours == null && nullToAbsent
          ? const Value.absent()
          : Value(experimentHours),
      practiceHours: practiceHours == null && nullToAbsent
          ? const Value.absent()
          : Value(practiceHours),
      sundayRaw: Value(sundayRaw),
      mondayRaw: Value(mondayRaw),
      tuesdayRaw: Value(tuesdayRaw),
      wednesdayRaw: Value(wednesdayRaw),
      thursdayRaw: Value(thursdayRaw),
      fridayRaw: Value(fridayRaw),
      saturdayRaw: Value(saturdayRaw),
      remark: Value(remark),
      otherTeachers: Value(otherTeachers),
      textbook: Value(textbook),
      publisher: Value(publisher),
      openDepartmentCode: Value(openDepartmentCode),
      collegeCode: Value(collegeCode),
      majorCode: Value(majorCode),
      gradeCode: Value(gradeCode),
      schoolYearCode: Value(schoolYearCode),
      termCode: Value(termCode),
      courseCategoryCode: Value(courseCategoryCode),
      conditionCode: Value(conditionCode),
      openTypeCode: Value(openTypeCode),
      courseNatureCode: Value(courseNatureCode),
      note: Value(note),
      scheduleSummary: Value(scheduleSummary),
      weekdaySummary: Value(weekdaySummary),
      searchText: Value(searchText),
      originalFieldsJson: Value(originalFieldsJson),
    );
  }

  factory CourseOfferingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseOfferingRow(
      id: serializer.fromJson<String>(json['id']),
      termKey: serializer.fromJson<String>(json['termKey']),
      termCourseId: serializer.fromJson<String>(json['termCourseId']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      instructorCourseId: serializer.fromJson<String>(
        json['instructorCourseId'],
      ),
      sourceKey: serializer.fromJson<String>(json['sourceKey']),
      packageIndex: serializer.fromJson<int>(json['packageIndex']),
      sourceStatus: serializer.fromJson<String>(json['sourceStatus']),
      schoolYear: serializer.fromJson<String>(json['schoolYear']),
      term: serializer.fromJson<String>(json['term']),
      teachingClassName: serializer.fromJson<String>(json['teachingClassName']),
      courseNo: serializer.fromJson<String>(json['courseNo']),
      courseName: serializer.fromJson<String>(json['courseName']),
      openCollege: serializer.fromJson<String>(json['openCollege']),
      planCollege: serializer.fromJson<String>(json['planCollege']),
      credits: serializer.fromJson<double?>(json['credits']),
      courseNature: serializer.fromJson<String>(json['courseNature']),
      courseCategory: serializer.fromJson<String>(json['courseCategory']),
      openType: serializer.fromJson<String>(json['openType']),
      grade: serializer.fromJson<String>(json['grade']),
      major: serializer.fromJson<String>(json['major']),
      instructor: serializer.fromJson<String>(json['instructor']),
      title: serializer.fromJson<String>(json['title']),
      peopleRaw: serializer.fromJson<String>(json['peopleRaw']),
      theoryHours: serializer.fromJson<int?>(json['theoryHours']),
      computerHours: serializer.fromJson<int?>(json['computerHours']),
      experimentHours: serializer.fromJson<int?>(json['experimentHours']),
      practiceHours: serializer.fromJson<int?>(json['practiceHours']),
      sundayRaw: serializer.fromJson<String>(json['sundayRaw']),
      mondayRaw: serializer.fromJson<String>(json['mondayRaw']),
      tuesdayRaw: serializer.fromJson<String>(json['tuesdayRaw']),
      wednesdayRaw: serializer.fromJson<String>(json['wednesdayRaw']),
      thursdayRaw: serializer.fromJson<String>(json['thursdayRaw']),
      fridayRaw: serializer.fromJson<String>(json['fridayRaw']),
      saturdayRaw: serializer.fromJson<String>(json['saturdayRaw']),
      remark: serializer.fromJson<String>(json['remark']),
      otherTeachers: serializer.fromJson<String>(json['otherTeachers']),
      textbook: serializer.fromJson<String>(json['textbook']),
      publisher: serializer.fromJson<String>(json['publisher']),
      openDepartmentCode: serializer.fromJson<String>(
        json['openDepartmentCode'],
      ),
      collegeCode: serializer.fromJson<String>(json['collegeCode']),
      majorCode: serializer.fromJson<String>(json['majorCode']),
      gradeCode: serializer.fromJson<String>(json['gradeCode']),
      schoolYearCode: serializer.fromJson<String>(json['schoolYearCode']),
      termCode: serializer.fromJson<String>(json['termCode']),
      courseCategoryCode: serializer.fromJson<String>(
        json['courseCategoryCode'],
      ),
      conditionCode: serializer.fromJson<String>(json['conditionCode']),
      openTypeCode: serializer.fromJson<String>(json['openTypeCode']),
      courseNatureCode: serializer.fromJson<String>(json['courseNatureCode']),
      note: serializer.fromJson<String>(json['note']),
      scheduleSummary: serializer.fromJson<String>(json['scheduleSummary']),
      weekdaySummary: serializer.fromJson<String>(json['weekdaySummary']),
      searchText: serializer.fromJson<String>(json['searchText']),
      originalFieldsJson: serializer.fromJson<String>(
        json['originalFieldsJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'termKey': serializer.toJson<String>(termKey),
      'termCourseId': serializer.toJson<String>(termCourseId),
      'catalogId': serializer.toJson<String>(catalogId),
      'instructorCourseId': serializer.toJson<String>(instructorCourseId),
      'sourceKey': serializer.toJson<String>(sourceKey),
      'packageIndex': serializer.toJson<int>(packageIndex),
      'sourceStatus': serializer.toJson<String>(sourceStatus),
      'schoolYear': serializer.toJson<String>(schoolYear),
      'term': serializer.toJson<String>(term),
      'teachingClassName': serializer.toJson<String>(teachingClassName),
      'courseNo': serializer.toJson<String>(courseNo),
      'courseName': serializer.toJson<String>(courseName),
      'openCollege': serializer.toJson<String>(openCollege),
      'planCollege': serializer.toJson<String>(planCollege),
      'credits': serializer.toJson<double?>(credits),
      'courseNature': serializer.toJson<String>(courseNature),
      'courseCategory': serializer.toJson<String>(courseCategory),
      'openType': serializer.toJson<String>(openType),
      'grade': serializer.toJson<String>(grade),
      'major': serializer.toJson<String>(major),
      'instructor': serializer.toJson<String>(instructor),
      'title': serializer.toJson<String>(title),
      'peopleRaw': serializer.toJson<String>(peopleRaw),
      'theoryHours': serializer.toJson<int?>(theoryHours),
      'computerHours': serializer.toJson<int?>(computerHours),
      'experimentHours': serializer.toJson<int?>(experimentHours),
      'practiceHours': serializer.toJson<int?>(practiceHours),
      'sundayRaw': serializer.toJson<String>(sundayRaw),
      'mondayRaw': serializer.toJson<String>(mondayRaw),
      'tuesdayRaw': serializer.toJson<String>(tuesdayRaw),
      'wednesdayRaw': serializer.toJson<String>(wednesdayRaw),
      'thursdayRaw': serializer.toJson<String>(thursdayRaw),
      'fridayRaw': serializer.toJson<String>(fridayRaw),
      'saturdayRaw': serializer.toJson<String>(saturdayRaw),
      'remark': serializer.toJson<String>(remark),
      'otherTeachers': serializer.toJson<String>(otherTeachers),
      'textbook': serializer.toJson<String>(textbook),
      'publisher': serializer.toJson<String>(publisher),
      'openDepartmentCode': serializer.toJson<String>(openDepartmentCode),
      'collegeCode': serializer.toJson<String>(collegeCode),
      'majorCode': serializer.toJson<String>(majorCode),
      'gradeCode': serializer.toJson<String>(gradeCode),
      'schoolYearCode': serializer.toJson<String>(schoolYearCode),
      'termCode': serializer.toJson<String>(termCode),
      'courseCategoryCode': serializer.toJson<String>(courseCategoryCode),
      'conditionCode': serializer.toJson<String>(conditionCode),
      'openTypeCode': serializer.toJson<String>(openTypeCode),
      'courseNatureCode': serializer.toJson<String>(courseNatureCode),
      'note': serializer.toJson<String>(note),
      'scheduleSummary': serializer.toJson<String>(scheduleSummary),
      'weekdaySummary': serializer.toJson<String>(weekdaySummary),
      'searchText': serializer.toJson<String>(searchText),
      'originalFieldsJson': serializer.toJson<String>(originalFieldsJson),
    };
  }

  CourseOfferingRow copyWith({
    String? id,
    String? termKey,
    String? termCourseId,
    String? catalogId,
    String? instructorCourseId,
    String? sourceKey,
    int? packageIndex,
    String? sourceStatus,
    String? schoolYear,
    String? term,
    String? teachingClassName,
    String? courseNo,
    String? courseName,
    String? openCollege,
    String? planCollege,
    Value<double?> credits = const Value.absent(),
    String? courseNature,
    String? courseCategory,
    String? openType,
    String? grade,
    String? major,
    String? instructor,
    String? title,
    String? peopleRaw,
    Value<int?> theoryHours = const Value.absent(),
    Value<int?> computerHours = const Value.absent(),
    Value<int?> experimentHours = const Value.absent(),
    Value<int?> practiceHours = const Value.absent(),
    String? sundayRaw,
    String? mondayRaw,
    String? tuesdayRaw,
    String? wednesdayRaw,
    String? thursdayRaw,
    String? fridayRaw,
    String? saturdayRaw,
    String? remark,
    String? otherTeachers,
    String? textbook,
    String? publisher,
    String? openDepartmentCode,
    String? collegeCode,
    String? majorCode,
    String? gradeCode,
    String? schoolYearCode,
    String? termCode,
    String? courseCategoryCode,
    String? conditionCode,
    String? openTypeCode,
    String? courseNatureCode,
    String? note,
    String? scheduleSummary,
    String? weekdaySummary,
    String? searchText,
    String? originalFieldsJson,
  }) => CourseOfferingRow(
    id: id ?? this.id,
    termKey: termKey ?? this.termKey,
    termCourseId: termCourseId ?? this.termCourseId,
    catalogId: catalogId ?? this.catalogId,
    instructorCourseId: instructorCourseId ?? this.instructorCourseId,
    sourceKey: sourceKey ?? this.sourceKey,
    packageIndex: packageIndex ?? this.packageIndex,
    sourceStatus: sourceStatus ?? this.sourceStatus,
    schoolYear: schoolYear ?? this.schoolYear,
    term: term ?? this.term,
    teachingClassName: teachingClassName ?? this.teachingClassName,
    courseNo: courseNo ?? this.courseNo,
    courseName: courseName ?? this.courseName,
    openCollege: openCollege ?? this.openCollege,
    planCollege: planCollege ?? this.planCollege,
    credits: credits.present ? credits.value : this.credits,
    courseNature: courseNature ?? this.courseNature,
    courseCategory: courseCategory ?? this.courseCategory,
    openType: openType ?? this.openType,
    grade: grade ?? this.grade,
    major: major ?? this.major,
    instructor: instructor ?? this.instructor,
    title: title ?? this.title,
    peopleRaw: peopleRaw ?? this.peopleRaw,
    theoryHours: theoryHours.present ? theoryHours.value : this.theoryHours,
    computerHours: computerHours.present
        ? computerHours.value
        : this.computerHours,
    experimentHours: experimentHours.present
        ? experimentHours.value
        : this.experimentHours,
    practiceHours: practiceHours.present
        ? practiceHours.value
        : this.practiceHours,
    sundayRaw: sundayRaw ?? this.sundayRaw,
    mondayRaw: mondayRaw ?? this.mondayRaw,
    tuesdayRaw: tuesdayRaw ?? this.tuesdayRaw,
    wednesdayRaw: wednesdayRaw ?? this.wednesdayRaw,
    thursdayRaw: thursdayRaw ?? this.thursdayRaw,
    fridayRaw: fridayRaw ?? this.fridayRaw,
    saturdayRaw: saturdayRaw ?? this.saturdayRaw,
    remark: remark ?? this.remark,
    otherTeachers: otherTeachers ?? this.otherTeachers,
    textbook: textbook ?? this.textbook,
    publisher: publisher ?? this.publisher,
    openDepartmentCode: openDepartmentCode ?? this.openDepartmentCode,
    collegeCode: collegeCode ?? this.collegeCode,
    majorCode: majorCode ?? this.majorCode,
    gradeCode: gradeCode ?? this.gradeCode,
    schoolYearCode: schoolYearCode ?? this.schoolYearCode,
    termCode: termCode ?? this.termCode,
    courseCategoryCode: courseCategoryCode ?? this.courseCategoryCode,
    conditionCode: conditionCode ?? this.conditionCode,
    openTypeCode: openTypeCode ?? this.openTypeCode,
    courseNatureCode: courseNatureCode ?? this.courseNatureCode,
    note: note ?? this.note,
    scheduleSummary: scheduleSummary ?? this.scheduleSummary,
    weekdaySummary: weekdaySummary ?? this.weekdaySummary,
    searchText: searchText ?? this.searchText,
    originalFieldsJson: originalFieldsJson ?? this.originalFieldsJson,
  );
  CourseOfferingRow copyWithCompanion(CourseOfferingRowsCompanion data) {
    return CourseOfferingRow(
      id: data.id.present ? data.id.value : this.id,
      termKey: data.termKey.present ? data.termKey.value : this.termKey,
      termCourseId: data.termCourseId.present
          ? data.termCourseId.value
          : this.termCourseId,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      instructorCourseId: data.instructorCourseId.present
          ? data.instructorCourseId.value
          : this.instructorCourseId,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      packageIndex: data.packageIndex.present
          ? data.packageIndex.value
          : this.packageIndex,
      sourceStatus: data.sourceStatus.present
          ? data.sourceStatus.value
          : this.sourceStatus,
      schoolYear: data.schoolYear.present
          ? data.schoolYear.value
          : this.schoolYear,
      term: data.term.present ? data.term.value : this.term,
      teachingClassName: data.teachingClassName.present
          ? data.teachingClassName.value
          : this.teachingClassName,
      courseNo: data.courseNo.present ? data.courseNo.value : this.courseNo,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      openCollege: data.openCollege.present
          ? data.openCollege.value
          : this.openCollege,
      planCollege: data.planCollege.present
          ? data.planCollege.value
          : this.planCollege,
      credits: data.credits.present ? data.credits.value : this.credits,
      courseNature: data.courseNature.present
          ? data.courseNature.value
          : this.courseNature,
      courseCategory: data.courseCategory.present
          ? data.courseCategory.value
          : this.courseCategory,
      openType: data.openType.present ? data.openType.value : this.openType,
      grade: data.grade.present ? data.grade.value : this.grade,
      major: data.major.present ? data.major.value : this.major,
      instructor: data.instructor.present
          ? data.instructor.value
          : this.instructor,
      title: data.title.present ? data.title.value : this.title,
      peopleRaw: data.peopleRaw.present ? data.peopleRaw.value : this.peopleRaw,
      theoryHours: data.theoryHours.present
          ? data.theoryHours.value
          : this.theoryHours,
      computerHours: data.computerHours.present
          ? data.computerHours.value
          : this.computerHours,
      experimentHours: data.experimentHours.present
          ? data.experimentHours.value
          : this.experimentHours,
      practiceHours: data.practiceHours.present
          ? data.practiceHours.value
          : this.practiceHours,
      sundayRaw: data.sundayRaw.present ? data.sundayRaw.value : this.sundayRaw,
      mondayRaw: data.mondayRaw.present ? data.mondayRaw.value : this.mondayRaw,
      tuesdayRaw: data.tuesdayRaw.present
          ? data.tuesdayRaw.value
          : this.tuesdayRaw,
      wednesdayRaw: data.wednesdayRaw.present
          ? data.wednesdayRaw.value
          : this.wednesdayRaw,
      thursdayRaw: data.thursdayRaw.present
          ? data.thursdayRaw.value
          : this.thursdayRaw,
      fridayRaw: data.fridayRaw.present ? data.fridayRaw.value : this.fridayRaw,
      saturdayRaw: data.saturdayRaw.present
          ? data.saturdayRaw.value
          : this.saturdayRaw,
      remark: data.remark.present ? data.remark.value : this.remark,
      otherTeachers: data.otherTeachers.present
          ? data.otherTeachers.value
          : this.otherTeachers,
      textbook: data.textbook.present ? data.textbook.value : this.textbook,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      openDepartmentCode: data.openDepartmentCode.present
          ? data.openDepartmentCode.value
          : this.openDepartmentCode,
      collegeCode: data.collegeCode.present
          ? data.collegeCode.value
          : this.collegeCode,
      majorCode: data.majorCode.present ? data.majorCode.value : this.majorCode,
      gradeCode: data.gradeCode.present ? data.gradeCode.value : this.gradeCode,
      schoolYearCode: data.schoolYearCode.present
          ? data.schoolYearCode.value
          : this.schoolYearCode,
      termCode: data.termCode.present ? data.termCode.value : this.termCode,
      courseCategoryCode: data.courseCategoryCode.present
          ? data.courseCategoryCode.value
          : this.courseCategoryCode,
      conditionCode: data.conditionCode.present
          ? data.conditionCode.value
          : this.conditionCode,
      openTypeCode: data.openTypeCode.present
          ? data.openTypeCode.value
          : this.openTypeCode,
      courseNatureCode: data.courseNatureCode.present
          ? data.courseNatureCode.value
          : this.courseNatureCode,
      note: data.note.present ? data.note.value : this.note,
      scheduleSummary: data.scheduleSummary.present
          ? data.scheduleSummary.value
          : this.scheduleSummary,
      weekdaySummary: data.weekdaySummary.present
          ? data.weekdaySummary.value
          : this.weekdaySummary,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      originalFieldsJson: data.originalFieldsJson.present
          ? data.originalFieldsJson.value
          : this.originalFieldsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseOfferingRow(')
          ..write('id: $id, ')
          ..write('termKey: $termKey, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('catalogId: $catalogId, ')
          ..write('instructorCourseId: $instructorCourseId, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('packageIndex: $packageIndex, ')
          ..write('sourceStatus: $sourceStatus, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('term: $term, ')
          ..write('teachingClassName: $teachingClassName, ')
          ..write('courseNo: $courseNo, ')
          ..write('courseName: $courseName, ')
          ..write('openCollege: $openCollege, ')
          ..write('planCollege: $planCollege, ')
          ..write('credits: $credits, ')
          ..write('courseNature: $courseNature, ')
          ..write('courseCategory: $courseCategory, ')
          ..write('openType: $openType, ')
          ..write('grade: $grade, ')
          ..write('major: $major, ')
          ..write('instructor: $instructor, ')
          ..write('title: $title, ')
          ..write('peopleRaw: $peopleRaw, ')
          ..write('theoryHours: $theoryHours, ')
          ..write('computerHours: $computerHours, ')
          ..write('experimentHours: $experimentHours, ')
          ..write('practiceHours: $practiceHours, ')
          ..write('sundayRaw: $sundayRaw, ')
          ..write('mondayRaw: $mondayRaw, ')
          ..write('tuesdayRaw: $tuesdayRaw, ')
          ..write('wednesdayRaw: $wednesdayRaw, ')
          ..write('thursdayRaw: $thursdayRaw, ')
          ..write('fridayRaw: $fridayRaw, ')
          ..write('saturdayRaw: $saturdayRaw, ')
          ..write('remark: $remark, ')
          ..write('otherTeachers: $otherTeachers, ')
          ..write('textbook: $textbook, ')
          ..write('publisher: $publisher, ')
          ..write('openDepartmentCode: $openDepartmentCode, ')
          ..write('collegeCode: $collegeCode, ')
          ..write('majorCode: $majorCode, ')
          ..write('gradeCode: $gradeCode, ')
          ..write('schoolYearCode: $schoolYearCode, ')
          ..write('termCode: $termCode, ')
          ..write('courseCategoryCode: $courseCategoryCode, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('openTypeCode: $openTypeCode, ')
          ..write('courseNatureCode: $courseNatureCode, ')
          ..write('note: $note, ')
          ..write('scheduleSummary: $scheduleSummary, ')
          ..write('weekdaySummary: $weekdaySummary, ')
          ..write('searchText: $searchText, ')
          ..write('originalFieldsJson: $originalFieldsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    termKey,
    termCourseId,
    catalogId,
    instructorCourseId,
    sourceKey,
    packageIndex,
    sourceStatus,
    schoolYear,
    term,
    teachingClassName,
    courseNo,
    courseName,
    openCollege,
    planCollege,
    credits,
    courseNature,
    courseCategory,
    openType,
    grade,
    major,
    instructor,
    title,
    peopleRaw,
    theoryHours,
    computerHours,
    experimentHours,
    practiceHours,
    sundayRaw,
    mondayRaw,
    tuesdayRaw,
    wednesdayRaw,
    thursdayRaw,
    fridayRaw,
    saturdayRaw,
    remark,
    otherTeachers,
    textbook,
    publisher,
    openDepartmentCode,
    collegeCode,
    majorCode,
    gradeCode,
    schoolYearCode,
    termCode,
    courseCategoryCode,
    conditionCode,
    openTypeCode,
    courseNatureCode,
    note,
    scheduleSummary,
    weekdaySummary,
    searchText,
    originalFieldsJson,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseOfferingRow &&
          other.id == this.id &&
          other.termKey == this.termKey &&
          other.termCourseId == this.termCourseId &&
          other.catalogId == this.catalogId &&
          other.instructorCourseId == this.instructorCourseId &&
          other.sourceKey == this.sourceKey &&
          other.packageIndex == this.packageIndex &&
          other.sourceStatus == this.sourceStatus &&
          other.schoolYear == this.schoolYear &&
          other.term == this.term &&
          other.teachingClassName == this.teachingClassName &&
          other.courseNo == this.courseNo &&
          other.courseName == this.courseName &&
          other.openCollege == this.openCollege &&
          other.planCollege == this.planCollege &&
          other.credits == this.credits &&
          other.courseNature == this.courseNature &&
          other.courseCategory == this.courseCategory &&
          other.openType == this.openType &&
          other.grade == this.grade &&
          other.major == this.major &&
          other.instructor == this.instructor &&
          other.title == this.title &&
          other.peopleRaw == this.peopleRaw &&
          other.theoryHours == this.theoryHours &&
          other.computerHours == this.computerHours &&
          other.experimentHours == this.experimentHours &&
          other.practiceHours == this.practiceHours &&
          other.sundayRaw == this.sundayRaw &&
          other.mondayRaw == this.mondayRaw &&
          other.tuesdayRaw == this.tuesdayRaw &&
          other.wednesdayRaw == this.wednesdayRaw &&
          other.thursdayRaw == this.thursdayRaw &&
          other.fridayRaw == this.fridayRaw &&
          other.saturdayRaw == this.saturdayRaw &&
          other.remark == this.remark &&
          other.otherTeachers == this.otherTeachers &&
          other.textbook == this.textbook &&
          other.publisher == this.publisher &&
          other.openDepartmentCode == this.openDepartmentCode &&
          other.collegeCode == this.collegeCode &&
          other.majorCode == this.majorCode &&
          other.gradeCode == this.gradeCode &&
          other.schoolYearCode == this.schoolYearCode &&
          other.termCode == this.termCode &&
          other.courseCategoryCode == this.courseCategoryCode &&
          other.conditionCode == this.conditionCode &&
          other.openTypeCode == this.openTypeCode &&
          other.courseNatureCode == this.courseNatureCode &&
          other.note == this.note &&
          other.scheduleSummary == this.scheduleSummary &&
          other.weekdaySummary == this.weekdaySummary &&
          other.searchText == this.searchText &&
          other.originalFieldsJson == this.originalFieldsJson);
}

class CourseOfferingRowsCompanion extends UpdateCompanion<CourseOfferingRow> {
  final Value<String> id;
  final Value<String> termKey;
  final Value<String> termCourseId;
  final Value<String> catalogId;
  final Value<String> instructorCourseId;
  final Value<String> sourceKey;
  final Value<int> packageIndex;
  final Value<String> sourceStatus;
  final Value<String> schoolYear;
  final Value<String> term;
  final Value<String> teachingClassName;
  final Value<String> courseNo;
  final Value<String> courseName;
  final Value<String> openCollege;
  final Value<String> planCollege;
  final Value<double?> credits;
  final Value<String> courseNature;
  final Value<String> courseCategory;
  final Value<String> openType;
  final Value<String> grade;
  final Value<String> major;
  final Value<String> instructor;
  final Value<String> title;
  final Value<String> peopleRaw;
  final Value<int?> theoryHours;
  final Value<int?> computerHours;
  final Value<int?> experimentHours;
  final Value<int?> practiceHours;
  final Value<String> sundayRaw;
  final Value<String> mondayRaw;
  final Value<String> tuesdayRaw;
  final Value<String> wednesdayRaw;
  final Value<String> thursdayRaw;
  final Value<String> fridayRaw;
  final Value<String> saturdayRaw;
  final Value<String> remark;
  final Value<String> otherTeachers;
  final Value<String> textbook;
  final Value<String> publisher;
  final Value<String> openDepartmentCode;
  final Value<String> collegeCode;
  final Value<String> majorCode;
  final Value<String> gradeCode;
  final Value<String> schoolYearCode;
  final Value<String> termCode;
  final Value<String> courseCategoryCode;
  final Value<String> conditionCode;
  final Value<String> openTypeCode;
  final Value<String> courseNatureCode;
  final Value<String> note;
  final Value<String> scheduleSummary;
  final Value<String> weekdaySummary;
  final Value<String> searchText;
  final Value<String> originalFieldsJson;
  final Value<int> rowid;
  const CourseOfferingRowsCompanion({
    this.id = const Value.absent(),
    this.termKey = const Value.absent(),
    this.termCourseId = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.instructorCourseId = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.packageIndex = const Value.absent(),
    this.sourceStatus = const Value.absent(),
    this.schoolYear = const Value.absent(),
    this.term = const Value.absent(),
    this.teachingClassName = const Value.absent(),
    this.courseNo = const Value.absent(),
    this.courseName = const Value.absent(),
    this.openCollege = const Value.absent(),
    this.planCollege = const Value.absent(),
    this.credits = const Value.absent(),
    this.courseNature = const Value.absent(),
    this.courseCategory = const Value.absent(),
    this.openType = const Value.absent(),
    this.grade = const Value.absent(),
    this.major = const Value.absent(),
    this.instructor = const Value.absent(),
    this.title = const Value.absent(),
    this.peopleRaw = const Value.absent(),
    this.theoryHours = const Value.absent(),
    this.computerHours = const Value.absent(),
    this.experimentHours = const Value.absent(),
    this.practiceHours = const Value.absent(),
    this.sundayRaw = const Value.absent(),
    this.mondayRaw = const Value.absent(),
    this.tuesdayRaw = const Value.absent(),
    this.wednesdayRaw = const Value.absent(),
    this.thursdayRaw = const Value.absent(),
    this.fridayRaw = const Value.absent(),
    this.saturdayRaw = const Value.absent(),
    this.remark = const Value.absent(),
    this.otherTeachers = const Value.absent(),
    this.textbook = const Value.absent(),
    this.publisher = const Value.absent(),
    this.openDepartmentCode = const Value.absent(),
    this.collegeCode = const Value.absent(),
    this.majorCode = const Value.absent(),
    this.gradeCode = const Value.absent(),
    this.schoolYearCode = const Value.absent(),
    this.termCode = const Value.absent(),
    this.courseCategoryCode = const Value.absent(),
    this.conditionCode = const Value.absent(),
    this.openTypeCode = const Value.absent(),
    this.courseNatureCode = const Value.absent(),
    this.note = const Value.absent(),
    this.scheduleSummary = const Value.absent(),
    this.weekdaySummary = const Value.absent(),
    this.searchText = const Value.absent(),
    this.originalFieldsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseOfferingRowsCompanion.insert({
    required String id,
    required String termKey,
    required String termCourseId,
    required String catalogId,
    required String instructorCourseId,
    required String sourceKey,
    this.packageIndex = const Value.absent(),
    this.sourceStatus = const Value.absent(),
    required String schoolYear,
    required String term,
    required String teachingClassName,
    required String courseNo,
    required String courseName,
    this.openCollege = const Value.absent(),
    this.planCollege = const Value.absent(),
    this.credits = const Value.absent(),
    this.courseNature = const Value.absent(),
    this.courseCategory = const Value.absent(),
    this.openType = const Value.absent(),
    this.grade = const Value.absent(),
    this.major = const Value.absent(),
    this.instructor = const Value.absent(),
    this.title = const Value.absent(),
    this.peopleRaw = const Value.absent(),
    this.theoryHours = const Value.absent(),
    this.computerHours = const Value.absent(),
    this.experimentHours = const Value.absent(),
    this.practiceHours = const Value.absent(),
    this.sundayRaw = const Value.absent(),
    this.mondayRaw = const Value.absent(),
    this.tuesdayRaw = const Value.absent(),
    this.wednesdayRaw = const Value.absent(),
    this.thursdayRaw = const Value.absent(),
    this.fridayRaw = const Value.absent(),
    this.saturdayRaw = const Value.absent(),
    this.remark = const Value.absent(),
    this.otherTeachers = const Value.absent(),
    this.textbook = const Value.absent(),
    this.publisher = const Value.absent(),
    this.openDepartmentCode = const Value.absent(),
    this.collegeCode = const Value.absent(),
    this.majorCode = const Value.absent(),
    this.gradeCode = const Value.absent(),
    this.schoolYearCode = const Value.absent(),
    this.termCode = const Value.absent(),
    this.courseCategoryCode = const Value.absent(),
    this.conditionCode = const Value.absent(),
    this.openTypeCode = const Value.absent(),
    this.courseNatureCode = const Value.absent(),
    this.note = const Value.absent(),
    this.scheduleSummary = const Value.absent(),
    this.weekdaySummary = const Value.absent(),
    this.searchText = const Value.absent(),
    this.originalFieldsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       termKey = Value(termKey),
       termCourseId = Value(termCourseId),
       catalogId = Value(catalogId),
       instructorCourseId = Value(instructorCourseId),
       sourceKey = Value(sourceKey),
       schoolYear = Value(schoolYear),
       term = Value(term),
       teachingClassName = Value(teachingClassName),
       courseNo = Value(courseNo),
       courseName = Value(courseName);
  static Insertable<CourseOfferingRow> custom({
    Expression<String>? id,
    Expression<String>? termKey,
    Expression<String>? termCourseId,
    Expression<String>? catalogId,
    Expression<String>? instructorCourseId,
    Expression<String>? sourceKey,
    Expression<int>? packageIndex,
    Expression<String>? sourceStatus,
    Expression<String>? schoolYear,
    Expression<String>? term,
    Expression<String>? teachingClassName,
    Expression<String>? courseNo,
    Expression<String>? courseName,
    Expression<String>? openCollege,
    Expression<String>? planCollege,
    Expression<double>? credits,
    Expression<String>? courseNature,
    Expression<String>? courseCategory,
    Expression<String>? openType,
    Expression<String>? grade,
    Expression<String>? major,
    Expression<String>? instructor,
    Expression<String>? title,
    Expression<String>? peopleRaw,
    Expression<int>? theoryHours,
    Expression<int>? computerHours,
    Expression<int>? experimentHours,
    Expression<int>? practiceHours,
    Expression<String>? sundayRaw,
    Expression<String>? mondayRaw,
    Expression<String>? tuesdayRaw,
    Expression<String>? wednesdayRaw,
    Expression<String>? thursdayRaw,
    Expression<String>? fridayRaw,
    Expression<String>? saturdayRaw,
    Expression<String>? remark,
    Expression<String>? otherTeachers,
    Expression<String>? textbook,
    Expression<String>? publisher,
    Expression<String>? openDepartmentCode,
    Expression<String>? collegeCode,
    Expression<String>? majorCode,
    Expression<String>? gradeCode,
    Expression<String>? schoolYearCode,
    Expression<String>? termCode,
    Expression<String>? courseCategoryCode,
    Expression<String>? conditionCode,
    Expression<String>? openTypeCode,
    Expression<String>? courseNatureCode,
    Expression<String>? note,
    Expression<String>? scheduleSummary,
    Expression<String>? weekdaySummary,
    Expression<String>? searchText,
    Expression<String>? originalFieldsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (termKey != null) 'term_key': termKey,
      if (termCourseId != null) 'term_course_id': termCourseId,
      if (catalogId != null) 'catalog_id': catalogId,
      if (instructorCourseId != null)
        'instructor_course_id': instructorCourseId,
      if (sourceKey != null) 'source_key': sourceKey,
      if (packageIndex != null) 'package_index': packageIndex,
      if (sourceStatus != null) 'source_status': sourceStatus,
      if (schoolYear != null) 'school_year': schoolYear,
      if (term != null) 'term': term,
      if (teachingClassName != null) 'teaching_class_name': teachingClassName,
      if (courseNo != null) 'course_no': courseNo,
      if (courseName != null) 'course_name': courseName,
      if (openCollege != null) 'open_college': openCollege,
      if (planCollege != null) 'plan_college': planCollege,
      if (credits != null) 'credits': credits,
      if (courseNature != null) 'course_nature': courseNature,
      if (courseCategory != null) 'course_category': courseCategory,
      if (openType != null) 'open_type': openType,
      if (grade != null) 'grade': grade,
      if (major != null) 'major': major,
      if (instructor != null) 'instructor': instructor,
      if (title != null) 'title': title,
      if (peopleRaw != null) 'people_raw': peopleRaw,
      if (theoryHours != null) 'theory_hours': theoryHours,
      if (computerHours != null) 'computer_hours': computerHours,
      if (experimentHours != null) 'experiment_hours': experimentHours,
      if (practiceHours != null) 'practice_hours': practiceHours,
      if (sundayRaw != null) 'sunday_raw': sundayRaw,
      if (mondayRaw != null) 'monday_raw': mondayRaw,
      if (tuesdayRaw != null) 'tuesday_raw': tuesdayRaw,
      if (wednesdayRaw != null) 'wednesday_raw': wednesdayRaw,
      if (thursdayRaw != null) 'thursday_raw': thursdayRaw,
      if (fridayRaw != null) 'friday_raw': fridayRaw,
      if (saturdayRaw != null) 'saturday_raw': saturdayRaw,
      if (remark != null) 'remark': remark,
      if (otherTeachers != null) 'other_teachers': otherTeachers,
      if (textbook != null) 'textbook': textbook,
      if (publisher != null) 'publisher': publisher,
      if (openDepartmentCode != null)
        'open_department_code': openDepartmentCode,
      if (collegeCode != null) 'college_code': collegeCode,
      if (majorCode != null) 'major_code': majorCode,
      if (gradeCode != null) 'grade_code': gradeCode,
      if (schoolYearCode != null) 'school_year_code': schoolYearCode,
      if (termCode != null) 'term_code': termCode,
      if (courseCategoryCode != null)
        'course_category_code': courseCategoryCode,
      if (conditionCode != null) 'condition_code': conditionCode,
      if (openTypeCode != null) 'open_type_code': openTypeCode,
      if (courseNatureCode != null) 'course_nature_code': courseNatureCode,
      if (note != null) 'note': note,
      if (scheduleSummary != null) 'schedule_summary': scheduleSummary,
      if (weekdaySummary != null) 'weekday_summary': weekdaySummary,
      if (searchText != null) 'search_text': searchText,
      if (originalFieldsJson != null)
        'original_fields_json': originalFieldsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseOfferingRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? termKey,
    Value<String>? termCourseId,
    Value<String>? catalogId,
    Value<String>? instructorCourseId,
    Value<String>? sourceKey,
    Value<int>? packageIndex,
    Value<String>? sourceStatus,
    Value<String>? schoolYear,
    Value<String>? term,
    Value<String>? teachingClassName,
    Value<String>? courseNo,
    Value<String>? courseName,
    Value<String>? openCollege,
    Value<String>? planCollege,
    Value<double?>? credits,
    Value<String>? courseNature,
    Value<String>? courseCategory,
    Value<String>? openType,
    Value<String>? grade,
    Value<String>? major,
    Value<String>? instructor,
    Value<String>? title,
    Value<String>? peopleRaw,
    Value<int?>? theoryHours,
    Value<int?>? computerHours,
    Value<int?>? experimentHours,
    Value<int?>? practiceHours,
    Value<String>? sundayRaw,
    Value<String>? mondayRaw,
    Value<String>? tuesdayRaw,
    Value<String>? wednesdayRaw,
    Value<String>? thursdayRaw,
    Value<String>? fridayRaw,
    Value<String>? saturdayRaw,
    Value<String>? remark,
    Value<String>? otherTeachers,
    Value<String>? textbook,
    Value<String>? publisher,
    Value<String>? openDepartmentCode,
    Value<String>? collegeCode,
    Value<String>? majorCode,
    Value<String>? gradeCode,
    Value<String>? schoolYearCode,
    Value<String>? termCode,
    Value<String>? courseCategoryCode,
    Value<String>? conditionCode,
    Value<String>? openTypeCode,
    Value<String>? courseNatureCode,
    Value<String>? note,
    Value<String>? scheduleSummary,
    Value<String>? weekdaySummary,
    Value<String>? searchText,
    Value<String>? originalFieldsJson,
    Value<int>? rowid,
  }) {
    return CourseOfferingRowsCompanion(
      id: id ?? this.id,
      termKey: termKey ?? this.termKey,
      termCourseId: termCourseId ?? this.termCourseId,
      catalogId: catalogId ?? this.catalogId,
      instructorCourseId: instructorCourseId ?? this.instructorCourseId,
      sourceKey: sourceKey ?? this.sourceKey,
      packageIndex: packageIndex ?? this.packageIndex,
      sourceStatus: sourceStatus ?? this.sourceStatus,
      schoolYear: schoolYear ?? this.schoolYear,
      term: term ?? this.term,
      teachingClassName: teachingClassName ?? this.teachingClassName,
      courseNo: courseNo ?? this.courseNo,
      courseName: courseName ?? this.courseName,
      openCollege: openCollege ?? this.openCollege,
      planCollege: planCollege ?? this.planCollege,
      credits: credits ?? this.credits,
      courseNature: courseNature ?? this.courseNature,
      courseCategory: courseCategory ?? this.courseCategory,
      openType: openType ?? this.openType,
      grade: grade ?? this.grade,
      major: major ?? this.major,
      instructor: instructor ?? this.instructor,
      title: title ?? this.title,
      peopleRaw: peopleRaw ?? this.peopleRaw,
      theoryHours: theoryHours ?? this.theoryHours,
      computerHours: computerHours ?? this.computerHours,
      experimentHours: experimentHours ?? this.experimentHours,
      practiceHours: practiceHours ?? this.practiceHours,
      sundayRaw: sundayRaw ?? this.sundayRaw,
      mondayRaw: mondayRaw ?? this.mondayRaw,
      tuesdayRaw: tuesdayRaw ?? this.tuesdayRaw,
      wednesdayRaw: wednesdayRaw ?? this.wednesdayRaw,
      thursdayRaw: thursdayRaw ?? this.thursdayRaw,
      fridayRaw: fridayRaw ?? this.fridayRaw,
      saturdayRaw: saturdayRaw ?? this.saturdayRaw,
      remark: remark ?? this.remark,
      otherTeachers: otherTeachers ?? this.otherTeachers,
      textbook: textbook ?? this.textbook,
      publisher: publisher ?? this.publisher,
      openDepartmentCode: openDepartmentCode ?? this.openDepartmentCode,
      collegeCode: collegeCode ?? this.collegeCode,
      majorCode: majorCode ?? this.majorCode,
      gradeCode: gradeCode ?? this.gradeCode,
      schoolYearCode: schoolYearCode ?? this.schoolYearCode,
      termCode: termCode ?? this.termCode,
      courseCategoryCode: courseCategoryCode ?? this.courseCategoryCode,
      conditionCode: conditionCode ?? this.conditionCode,
      openTypeCode: openTypeCode ?? this.openTypeCode,
      courseNatureCode: courseNatureCode ?? this.courseNatureCode,
      note: note ?? this.note,
      scheduleSummary: scheduleSummary ?? this.scheduleSummary,
      weekdaySummary: weekdaySummary ?? this.weekdaySummary,
      searchText: searchText ?? this.searchText,
      originalFieldsJson: originalFieldsJson ?? this.originalFieldsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (termKey.present) {
      map['term_key'] = Variable<String>(termKey.value);
    }
    if (termCourseId.present) {
      map['term_course_id'] = Variable<String>(termCourseId.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (instructorCourseId.present) {
      map['instructor_course_id'] = Variable<String>(instructorCourseId.value);
    }
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (packageIndex.present) {
      map['package_index'] = Variable<int>(packageIndex.value);
    }
    if (sourceStatus.present) {
      map['source_status'] = Variable<String>(sourceStatus.value);
    }
    if (schoolYear.present) {
      map['school_year'] = Variable<String>(schoolYear.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (teachingClassName.present) {
      map['teaching_class_name'] = Variable<String>(teachingClassName.value);
    }
    if (courseNo.present) {
      map['course_no'] = Variable<String>(courseNo.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (openCollege.present) {
      map['open_college'] = Variable<String>(openCollege.value);
    }
    if (planCollege.present) {
      map['plan_college'] = Variable<String>(planCollege.value);
    }
    if (credits.present) {
      map['credits'] = Variable<double>(credits.value);
    }
    if (courseNature.present) {
      map['course_nature'] = Variable<String>(courseNature.value);
    }
    if (courseCategory.present) {
      map['course_category'] = Variable<String>(courseCategory.value);
    }
    if (openType.present) {
      map['open_type'] = Variable<String>(openType.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (major.present) {
      map['major'] = Variable<String>(major.value);
    }
    if (instructor.present) {
      map['instructor'] = Variable<String>(instructor.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (peopleRaw.present) {
      map['people_raw'] = Variable<String>(peopleRaw.value);
    }
    if (theoryHours.present) {
      map['theory_hours'] = Variable<int>(theoryHours.value);
    }
    if (computerHours.present) {
      map['computer_hours'] = Variable<int>(computerHours.value);
    }
    if (experimentHours.present) {
      map['experiment_hours'] = Variable<int>(experimentHours.value);
    }
    if (practiceHours.present) {
      map['practice_hours'] = Variable<int>(practiceHours.value);
    }
    if (sundayRaw.present) {
      map['sunday_raw'] = Variable<String>(sundayRaw.value);
    }
    if (mondayRaw.present) {
      map['monday_raw'] = Variable<String>(mondayRaw.value);
    }
    if (tuesdayRaw.present) {
      map['tuesday_raw'] = Variable<String>(tuesdayRaw.value);
    }
    if (wednesdayRaw.present) {
      map['wednesday_raw'] = Variable<String>(wednesdayRaw.value);
    }
    if (thursdayRaw.present) {
      map['thursday_raw'] = Variable<String>(thursdayRaw.value);
    }
    if (fridayRaw.present) {
      map['friday_raw'] = Variable<String>(fridayRaw.value);
    }
    if (saturdayRaw.present) {
      map['saturday_raw'] = Variable<String>(saturdayRaw.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (otherTeachers.present) {
      map['other_teachers'] = Variable<String>(otherTeachers.value);
    }
    if (textbook.present) {
      map['textbook'] = Variable<String>(textbook.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (openDepartmentCode.present) {
      map['open_department_code'] = Variable<String>(openDepartmentCode.value);
    }
    if (collegeCode.present) {
      map['college_code'] = Variable<String>(collegeCode.value);
    }
    if (majorCode.present) {
      map['major_code'] = Variable<String>(majorCode.value);
    }
    if (gradeCode.present) {
      map['grade_code'] = Variable<String>(gradeCode.value);
    }
    if (schoolYearCode.present) {
      map['school_year_code'] = Variable<String>(schoolYearCode.value);
    }
    if (termCode.present) {
      map['term_code'] = Variable<String>(termCode.value);
    }
    if (courseCategoryCode.present) {
      map['course_category_code'] = Variable<String>(courseCategoryCode.value);
    }
    if (conditionCode.present) {
      map['condition_code'] = Variable<String>(conditionCode.value);
    }
    if (openTypeCode.present) {
      map['open_type_code'] = Variable<String>(openTypeCode.value);
    }
    if (courseNatureCode.present) {
      map['course_nature_code'] = Variable<String>(courseNatureCode.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (scheduleSummary.present) {
      map['schedule_summary'] = Variable<String>(scheduleSummary.value);
    }
    if (weekdaySummary.present) {
      map['weekday_summary'] = Variable<String>(weekdaySummary.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (originalFieldsJson.present) {
      map['original_fields_json'] = Variable<String>(originalFieldsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseOfferingRowsCompanion(')
          ..write('id: $id, ')
          ..write('termKey: $termKey, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('catalogId: $catalogId, ')
          ..write('instructorCourseId: $instructorCourseId, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('packageIndex: $packageIndex, ')
          ..write('sourceStatus: $sourceStatus, ')
          ..write('schoolYear: $schoolYear, ')
          ..write('term: $term, ')
          ..write('teachingClassName: $teachingClassName, ')
          ..write('courseNo: $courseNo, ')
          ..write('courseName: $courseName, ')
          ..write('openCollege: $openCollege, ')
          ..write('planCollege: $planCollege, ')
          ..write('credits: $credits, ')
          ..write('courseNature: $courseNature, ')
          ..write('courseCategory: $courseCategory, ')
          ..write('openType: $openType, ')
          ..write('grade: $grade, ')
          ..write('major: $major, ')
          ..write('instructor: $instructor, ')
          ..write('title: $title, ')
          ..write('peopleRaw: $peopleRaw, ')
          ..write('theoryHours: $theoryHours, ')
          ..write('computerHours: $computerHours, ')
          ..write('experimentHours: $experimentHours, ')
          ..write('practiceHours: $practiceHours, ')
          ..write('sundayRaw: $sundayRaw, ')
          ..write('mondayRaw: $mondayRaw, ')
          ..write('tuesdayRaw: $tuesdayRaw, ')
          ..write('wednesdayRaw: $wednesdayRaw, ')
          ..write('thursdayRaw: $thursdayRaw, ')
          ..write('fridayRaw: $fridayRaw, ')
          ..write('saturdayRaw: $saturdayRaw, ')
          ..write('remark: $remark, ')
          ..write('otherTeachers: $otherTeachers, ')
          ..write('textbook: $textbook, ')
          ..write('publisher: $publisher, ')
          ..write('openDepartmentCode: $openDepartmentCode, ')
          ..write('collegeCode: $collegeCode, ')
          ..write('majorCode: $majorCode, ')
          ..write('gradeCode: $gradeCode, ')
          ..write('schoolYearCode: $schoolYearCode, ')
          ..write('termCode: $termCode, ')
          ..write('courseCategoryCode: $courseCategoryCode, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('openTypeCode: $openTypeCode, ')
          ..write('courseNatureCode: $courseNatureCode, ')
          ..write('note: $note, ')
          ..write('scheduleSummary: $scheduleSummary, ')
          ..write('weekdaySummary: $weekdaySummary, ')
          ..write('searchText: $searchText, ')
          ..write('originalFieldsJson: $originalFieldsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseAudienceRowsTable extends CourseAudienceRows
    with TableInfo<$CourseAudienceRowsTable, CourseAudienceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseAudienceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termKeyMeta = const VerificationMeta(
    'termKey',
  );
  @override
  late final GeneratedColumn<String> termKey = GeneratedColumn<String>(
    'term_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES school_timetable_term_rows (term_key)',
    ),
  );
  static const VerificationMeta _offeringIdMeta = const VerificationMeta(
    'offeringId',
  );
  @override
  late final GeneratedColumn<String> offeringId = GeneratedColumn<String>(
    'offering_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_offering_rows (id)',
    ),
  );
  static const VerificationMeta _termCourseIdMeta = const VerificationMeta(
    'termCourseId',
  );
  @override
  late final GeneratedColumn<String> termCourseId = GeneratedColumn<String>(
    'term_course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_term_course_rows (id)',
    ),
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_catalog_rows (id)',
    ),
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _majorMeta = const VerificationMeta('major');
  @override
  late final GeneratedColumn<String> major = GeneratedColumn<String>(
    'major',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _planCollegeMeta = const VerificationMeta(
    'planCollege',
  );
  @override
  late final GeneratedColumn<String> planCollege = GeneratedColumn<String>(
    'plan_college',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseNatureMeta = const VerificationMeta(
    'courseNature',
  );
  @override
  late final GeneratedColumn<String> courseNature = GeneratedColumn<String>(
    'course_nature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseNatureCodeMeta = const VerificationMeta(
    'courseNatureCode',
  );
  @override
  late final GeneratedColumn<String> courseNatureCode = GeneratedColumn<String>(
    'course_nature_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseCategoryMeta = const VerificationMeta(
    'courseCategory',
  );
  @override
  late final GeneratedColumn<String> courseCategory = GeneratedColumn<String>(
    'course_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _courseCategoryCodeMeta =
      const VerificationMeta('courseCategoryCode');
  @override
  late final GeneratedColumn<String> courseCategoryCode =
      GeneratedColumn<String>(
        'course_category_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _openTypeMeta = const VerificationMeta(
    'openType',
  );
  @override
  late final GeneratedColumn<String> openType = GeneratedColumn<String>(
    'open_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _openTypeCodeMeta = const VerificationMeta(
    'openTypeCode',
  );
  @override
  late final GeneratedColumn<String> openTypeCode = GeneratedColumn<String>(
    'open_type_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _conditionCodeMeta = const VerificationMeta(
    'conditionCode',
  );
  @override
  late final GeneratedColumn<String> conditionCode = GeneratedColumn<String>(
    'condition_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    termKey,
    offeringId,
    termCourseId,
    catalogId,
    grade,
    major,
    planCollege,
    courseNature,
    courseNatureCode,
    courseCategory,
    courseCategoryCode,
    openType,
    openTypeCode,
    conditionCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_audience_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseAudienceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('term_key')) {
      context.handle(
        _termKeyMeta,
        termKey.isAcceptableOrUnknown(data['term_key']!, _termKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_termKeyMeta);
    }
    if (data.containsKey('offering_id')) {
      context.handle(
        _offeringIdMeta,
        offeringId.isAcceptableOrUnknown(data['offering_id']!, _offeringIdMeta),
      );
    } else if (isInserting) {
      context.missing(_offeringIdMeta);
    }
    if (data.containsKey('term_course_id')) {
      context.handle(
        _termCourseIdMeta,
        termCourseId.isAcceptableOrUnknown(
          data['term_course_id']!,
          _termCourseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_termCourseIdMeta);
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('major')) {
      context.handle(
        _majorMeta,
        major.isAcceptableOrUnknown(data['major']!, _majorMeta),
      );
    }
    if (data.containsKey('plan_college')) {
      context.handle(
        _planCollegeMeta,
        planCollege.isAcceptableOrUnknown(
          data['plan_college']!,
          _planCollegeMeta,
        ),
      );
    }
    if (data.containsKey('course_nature')) {
      context.handle(
        _courseNatureMeta,
        courseNature.isAcceptableOrUnknown(
          data['course_nature']!,
          _courseNatureMeta,
        ),
      );
    }
    if (data.containsKey('course_nature_code')) {
      context.handle(
        _courseNatureCodeMeta,
        courseNatureCode.isAcceptableOrUnknown(
          data['course_nature_code']!,
          _courseNatureCodeMeta,
        ),
      );
    }
    if (data.containsKey('course_category')) {
      context.handle(
        _courseCategoryMeta,
        courseCategory.isAcceptableOrUnknown(
          data['course_category']!,
          _courseCategoryMeta,
        ),
      );
    }
    if (data.containsKey('course_category_code')) {
      context.handle(
        _courseCategoryCodeMeta,
        courseCategoryCode.isAcceptableOrUnknown(
          data['course_category_code']!,
          _courseCategoryCodeMeta,
        ),
      );
    }
    if (data.containsKey('open_type')) {
      context.handle(
        _openTypeMeta,
        openType.isAcceptableOrUnknown(data['open_type']!, _openTypeMeta),
      );
    }
    if (data.containsKey('open_type_code')) {
      context.handle(
        _openTypeCodeMeta,
        openTypeCode.isAcceptableOrUnknown(
          data['open_type_code']!,
          _openTypeCodeMeta,
        ),
      );
    }
    if (data.containsKey('condition_code')) {
      context.handle(
        _conditionCodeMeta,
        conditionCode.isAcceptableOrUnknown(
          data['condition_code']!,
          _conditionCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseAudienceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseAudienceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      termKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_key'],
      )!,
      offeringId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offering_id'],
      )!,
      termCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_course_id'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      )!,
      major: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}major'],
      )!,
      planCollege: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_college'],
      )!,
      courseNature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_nature'],
      )!,
      courseNatureCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_nature_code'],
      )!,
      courseCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_category'],
      )!,
      courseCategoryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_category_code'],
      )!,
      openType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_type'],
      )!,
      openTypeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_type_code'],
      )!,
      conditionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_code'],
      )!,
    );
  }

  @override
  $CourseAudienceRowsTable createAlias(String alias) {
    return $CourseAudienceRowsTable(attachedDatabase, alias);
  }
}

class CourseAudienceRow extends DataClass
    implements Insertable<CourseAudienceRow> {
  final String id;
  final String termKey;
  final String offeringId;
  final String termCourseId;
  final String catalogId;
  final String grade;
  final String major;
  final String planCollege;
  final String courseNature;
  final String courseNatureCode;
  final String courseCategory;
  final String courseCategoryCode;
  final String openType;
  final String openTypeCode;
  final String conditionCode;
  const CourseAudienceRow({
    required this.id,
    required this.termKey,
    required this.offeringId,
    required this.termCourseId,
    required this.catalogId,
    required this.grade,
    required this.major,
    required this.planCollege,
    required this.courseNature,
    required this.courseNatureCode,
    required this.courseCategory,
    required this.courseCategoryCode,
    required this.openType,
    required this.openTypeCode,
    required this.conditionCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['term_key'] = Variable<String>(termKey);
    map['offering_id'] = Variable<String>(offeringId);
    map['term_course_id'] = Variable<String>(termCourseId);
    map['catalog_id'] = Variable<String>(catalogId);
    map['grade'] = Variable<String>(grade);
    map['major'] = Variable<String>(major);
    map['plan_college'] = Variable<String>(planCollege);
    map['course_nature'] = Variable<String>(courseNature);
    map['course_nature_code'] = Variable<String>(courseNatureCode);
    map['course_category'] = Variable<String>(courseCategory);
    map['course_category_code'] = Variable<String>(courseCategoryCode);
    map['open_type'] = Variable<String>(openType);
    map['open_type_code'] = Variable<String>(openTypeCode);
    map['condition_code'] = Variable<String>(conditionCode);
    return map;
  }

  CourseAudienceRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseAudienceRowsCompanion(
      id: Value(id),
      termKey: Value(termKey),
      offeringId: Value(offeringId),
      termCourseId: Value(termCourseId),
      catalogId: Value(catalogId),
      grade: Value(grade),
      major: Value(major),
      planCollege: Value(planCollege),
      courseNature: Value(courseNature),
      courseNatureCode: Value(courseNatureCode),
      courseCategory: Value(courseCategory),
      courseCategoryCode: Value(courseCategoryCode),
      openType: Value(openType),
      openTypeCode: Value(openTypeCode),
      conditionCode: Value(conditionCode),
    );
  }

  factory CourseAudienceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseAudienceRow(
      id: serializer.fromJson<String>(json['id']),
      termKey: serializer.fromJson<String>(json['termKey']),
      offeringId: serializer.fromJson<String>(json['offeringId']),
      termCourseId: serializer.fromJson<String>(json['termCourseId']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      grade: serializer.fromJson<String>(json['grade']),
      major: serializer.fromJson<String>(json['major']),
      planCollege: serializer.fromJson<String>(json['planCollege']),
      courseNature: serializer.fromJson<String>(json['courseNature']),
      courseNatureCode: serializer.fromJson<String>(json['courseNatureCode']),
      courseCategory: serializer.fromJson<String>(json['courseCategory']),
      courseCategoryCode: serializer.fromJson<String>(
        json['courseCategoryCode'],
      ),
      openType: serializer.fromJson<String>(json['openType']),
      openTypeCode: serializer.fromJson<String>(json['openTypeCode']),
      conditionCode: serializer.fromJson<String>(json['conditionCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'termKey': serializer.toJson<String>(termKey),
      'offeringId': serializer.toJson<String>(offeringId),
      'termCourseId': serializer.toJson<String>(termCourseId),
      'catalogId': serializer.toJson<String>(catalogId),
      'grade': serializer.toJson<String>(grade),
      'major': serializer.toJson<String>(major),
      'planCollege': serializer.toJson<String>(planCollege),
      'courseNature': serializer.toJson<String>(courseNature),
      'courseNatureCode': serializer.toJson<String>(courseNatureCode),
      'courseCategory': serializer.toJson<String>(courseCategory),
      'courseCategoryCode': serializer.toJson<String>(courseCategoryCode),
      'openType': serializer.toJson<String>(openType),
      'openTypeCode': serializer.toJson<String>(openTypeCode),
      'conditionCode': serializer.toJson<String>(conditionCode),
    };
  }

  CourseAudienceRow copyWith({
    String? id,
    String? termKey,
    String? offeringId,
    String? termCourseId,
    String? catalogId,
    String? grade,
    String? major,
    String? planCollege,
    String? courseNature,
    String? courseNatureCode,
    String? courseCategory,
    String? courseCategoryCode,
    String? openType,
    String? openTypeCode,
    String? conditionCode,
  }) => CourseAudienceRow(
    id: id ?? this.id,
    termKey: termKey ?? this.termKey,
    offeringId: offeringId ?? this.offeringId,
    termCourseId: termCourseId ?? this.termCourseId,
    catalogId: catalogId ?? this.catalogId,
    grade: grade ?? this.grade,
    major: major ?? this.major,
    planCollege: planCollege ?? this.planCollege,
    courseNature: courseNature ?? this.courseNature,
    courseNatureCode: courseNatureCode ?? this.courseNatureCode,
    courseCategory: courseCategory ?? this.courseCategory,
    courseCategoryCode: courseCategoryCode ?? this.courseCategoryCode,
    openType: openType ?? this.openType,
    openTypeCode: openTypeCode ?? this.openTypeCode,
    conditionCode: conditionCode ?? this.conditionCode,
  );
  CourseAudienceRow copyWithCompanion(CourseAudienceRowsCompanion data) {
    return CourseAudienceRow(
      id: data.id.present ? data.id.value : this.id,
      termKey: data.termKey.present ? data.termKey.value : this.termKey,
      offeringId: data.offeringId.present
          ? data.offeringId.value
          : this.offeringId,
      termCourseId: data.termCourseId.present
          ? data.termCourseId.value
          : this.termCourseId,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      grade: data.grade.present ? data.grade.value : this.grade,
      major: data.major.present ? data.major.value : this.major,
      planCollege: data.planCollege.present
          ? data.planCollege.value
          : this.planCollege,
      courseNature: data.courseNature.present
          ? data.courseNature.value
          : this.courseNature,
      courseNatureCode: data.courseNatureCode.present
          ? data.courseNatureCode.value
          : this.courseNatureCode,
      courseCategory: data.courseCategory.present
          ? data.courseCategory.value
          : this.courseCategory,
      courseCategoryCode: data.courseCategoryCode.present
          ? data.courseCategoryCode.value
          : this.courseCategoryCode,
      openType: data.openType.present ? data.openType.value : this.openType,
      openTypeCode: data.openTypeCode.present
          ? data.openTypeCode.value
          : this.openTypeCode,
      conditionCode: data.conditionCode.present
          ? data.conditionCode.value
          : this.conditionCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseAudienceRow(')
          ..write('id: $id, ')
          ..write('termKey: $termKey, ')
          ..write('offeringId: $offeringId, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('catalogId: $catalogId, ')
          ..write('grade: $grade, ')
          ..write('major: $major, ')
          ..write('planCollege: $planCollege, ')
          ..write('courseNature: $courseNature, ')
          ..write('courseNatureCode: $courseNatureCode, ')
          ..write('courseCategory: $courseCategory, ')
          ..write('courseCategoryCode: $courseCategoryCode, ')
          ..write('openType: $openType, ')
          ..write('openTypeCode: $openTypeCode, ')
          ..write('conditionCode: $conditionCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    termKey,
    offeringId,
    termCourseId,
    catalogId,
    grade,
    major,
    planCollege,
    courseNature,
    courseNatureCode,
    courseCategory,
    courseCategoryCode,
    openType,
    openTypeCode,
    conditionCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseAudienceRow &&
          other.id == this.id &&
          other.termKey == this.termKey &&
          other.offeringId == this.offeringId &&
          other.termCourseId == this.termCourseId &&
          other.catalogId == this.catalogId &&
          other.grade == this.grade &&
          other.major == this.major &&
          other.planCollege == this.planCollege &&
          other.courseNature == this.courseNature &&
          other.courseNatureCode == this.courseNatureCode &&
          other.courseCategory == this.courseCategory &&
          other.courseCategoryCode == this.courseCategoryCode &&
          other.openType == this.openType &&
          other.openTypeCode == this.openTypeCode &&
          other.conditionCode == this.conditionCode);
}

class CourseAudienceRowsCompanion extends UpdateCompanion<CourseAudienceRow> {
  final Value<String> id;
  final Value<String> termKey;
  final Value<String> offeringId;
  final Value<String> termCourseId;
  final Value<String> catalogId;
  final Value<String> grade;
  final Value<String> major;
  final Value<String> planCollege;
  final Value<String> courseNature;
  final Value<String> courseNatureCode;
  final Value<String> courseCategory;
  final Value<String> courseCategoryCode;
  final Value<String> openType;
  final Value<String> openTypeCode;
  final Value<String> conditionCode;
  final Value<int> rowid;
  const CourseAudienceRowsCompanion({
    this.id = const Value.absent(),
    this.termKey = const Value.absent(),
    this.offeringId = const Value.absent(),
    this.termCourseId = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.grade = const Value.absent(),
    this.major = const Value.absent(),
    this.planCollege = const Value.absent(),
    this.courseNature = const Value.absent(),
    this.courseNatureCode = const Value.absent(),
    this.courseCategory = const Value.absent(),
    this.courseCategoryCode = const Value.absent(),
    this.openType = const Value.absent(),
    this.openTypeCode = const Value.absent(),
    this.conditionCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseAudienceRowsCompanion.insert({
    required String id,
    required String termKey,
    required String offeringId,
    required String termCourseId,
    required String catalogId,
    this.grade = const Value.absent(),
    this.major = const Value.absent(),
    this.planCollege = const Value.absent(),
    this.courseNature = const Value.absent(),
    this.courseNatureCode = const Value.absent(),
    this.courseCategory = const Value.absent(),
    this.courseCategoryCode = const Value.absent(),
    this.openType = const Value.absent(),
    this.openTypeCode = const Value.absent(),
    this.conditionCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       termKey = Value(termKey),
       offeringId = Value(offeringId),
       termCourseId = Value(termCourseId),
       catalogId = Value(catalogId);
  static Insertable<CourseAudienceRow> custom({
    Expression<String>? id,
    Expression<String>? termKey,
    Expression<String>? offeringId,
    Expression<String>? termCourseId,
    Expression<String>? catalogId,
    Expression<String>? grade,
    Expression<String>? major,
    Expression<String>? planCollege,
    Expression<String>? courseNature,
    Expression<String>? courseNatureCode,
    Expression<String>? courseCategory,
    Expression<String>? courseCategoryCode,
    Expression<String>? openType,
    Expression<String>? openTypeCode,
    Expression<String>? conditionCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (termKey != null) 'term_key': termKey,
      if (offeringId != null) 'offering_id': offeringId,
      if (termCourseId != null) 'term_course_id': termCourseId,
      if (catalogId != null) 'catalog_id': catalogId,
      if (grade != null) 'grade': grade,
      if (major != null) 'major': major,
      if (planCollege != null) 'plan_college': planCollege,
      if (courseNature != null) 'course_nature': courseNature,
      if (courseNatureCode != null) 'course_nature_code': courseNatureCode,
      if (courseCategory != null) 'course_category': courseCategory,
      if (courseCategoryCode != null)
        'course_category_code': courseCategoryCode,
      if (openType != null) 'open_type': openType,
      if (openTypeCode != null) 'open_type_code': openTypeCode,
      if (conditionCode != null) 'condition_code': conditionCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseAudienceRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? termKey,
    Value<String>? offeringId,
    Value<String>? termCourseId,
    Value<String>? catalogId,
    Value<String>? grade,
    Value<String>? major,
    Value<String>? planCollege,
    Value<String>? courseNature,
    Value<String>? courseNatureCode,
    Value<String>? courseCategory,
    Value<String>? courseCategoryCode,
    Value<String>? openType,
    Value<String>? openTypeCode,
    Value<String>? conditionCode,
    Value<int>? rowid,
  }) {
    return CourseAudienceRowsCompanion(
      id: id ?? this.id,
      termKey: termKey ?? this.termKey,
      offeringId: offeringId ?? this.offeringId,
      termCourseId: termCourseId ?? this.termCourseId,
      catalogId: catalogId ?? this.catalogId,
      grade: grade ?? this.grade,
      major: major ?? this.major,
      planCollege: planCollege ?? this.planCollege,
      courseNature: courseNature ?? this.courseNature,
      courseNatureCode: courseNatureCode ?? this.courseNatureCode,
      courseCategory: courseCategory ?? this.courseCategory,
      courseCategoryCode: courseCategoryCode ?? this.courseCategoryCode,
      openType: openType ?? this.openType,
      openTypeCode: openTypeCode ?? this.openTypeCode,
      conditionCode: conditionCode ?? this.conditionCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (termKey.present) {
      map['term_key'] = Variable<String>(termKey.value);
    }
    if (offeringId.present) {
      map['offering_id'] = Variable<String>(offeringId.value);
    }
    if (termCourseId.present) {
      map['term_course_id'] = Variable<String>(termCourseId.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (major.present) {
      map['major'] = Variable<String>(major.value);
    }
    if (planCollege.present) {
      map['plan_college'] = Variable<String>(planCollege.value);
    }
    if (courseNature.present) {
      map['course_nature'] = Variable<String>(courseNature.value);
    }
    if (courseNatureCode.present) {
      map['course_nature_code'] = Variable<String>(courseNatureCode.value);
    }
    if (courseCategory.present) {
      map['course_category'] = Variable<String>(courseCategory.value);
    }
    if (courseCategoryCode.present) {
      map['course_category_code'] = Variable<String>(courseCategoryCode.value);
    }
    if (openType.present) {
      map['open_type'] = Variable<String>(openType.value);
    }
    if (openTypeCode.present) {
      map['open_type_code'] = Variable<String>(openTypeCode.value);
    }
    if (conditionCode.present) {
      map['condition_code'] = Variable<String>(conditionCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseAudienceRowsCompanion(')
          ..write('id: $id, ')
          ..write('termKey: $termKey, ')
          ..write('offeringId: $offeringId, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('catalogId: $catalogId, ')
          ..write('grade: $grade, ')
          ..write('major: $major, ')
          ..write('planCollege: $planCollege, ')
          ..write('courseNature: $courseNature, ')
          ..write('courseNatureCode: $courseNatureCode, ')
          ..write('courseCategory: $courseCategory, ')
          ..write('courseCategoryCode: $courseCategoryCode, ')
          ..write('openType: $openType, ')
          ..write('openTypeCode: $openTypeCode, ')
          ..write('conditionCode: $conditionCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseSourceRowsTable extends CourseSourceRows
    with TableInfo<$CourseSourceRowsTable, CourseSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseSourceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termKeyMeta = const VerificationMeta(
    'termKey',
  );
  @override
  late final GeneratedColumn<String> termKey = GeneratedColumn<String>(
    'term_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES school_timetable_term_rows (term_key)',
    ),
  );
  static const VerificationMeta _termCourseIdMeta = const VerificationMeta(
    'termCourseId',
  );
  @override
  late final GeneratedColumn<String> termCourseId = GeneratedColumn<String>(
    'term_course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _offeringIdMeta = const VerificationMeta(
    'offeringId',
  );
  @override
  late final GeneratedColumn<String> offeringId = GeneratedColumn<String>(
    'offering_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  @override
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _packageIndexMeta = const VerificationMeta(
    'packageIndex',
  );
  @override
  late final GeneratedColumn<int> packageIndex = GeneratedColumn<int>(
    'package_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceStatusMeta = const VerificationMeta(
    'sourceStatus',
  );
  @override
  late final GeneratedColumn<String> sourceStatus = GeneratedColumn<String>(
    'source_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _originalFieldsJsonMeta =
      const VerificationMeta('originalFieldsJson');
  @override
  late final GeneratedColumn<String> originalFieldsJson =
      GeneratedColumn<String>(
        'original_fields_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    termKey,
    termCourseId,
    offeringId,
    sourceKey,
    packageIndex,
    sourceStatus,
    originalFieldsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_source_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('term_key')) {
      context.handle(
        _termKeyMeta,
        termKey.isAcceptableOrUnknown(data['term_key']!, _termKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_termKeyMeta);
    }
    if (data.containsKey('term_course_id')) {
      context.handle(
        _termCourseIdMeta,
        termCourseId.isAcceptableOrUnknown(
          data['term_course_id']!,
          _termCourseIdMeta,
        ),
      );
    }
    if (data.containsKey('offering_id')) {
      context.handle(
        _offeringIdMeta,
        offeringId.isAcceptableOrUnknown(data['offering_id']!, _offeringIdMeta),
      );
    }
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    }
    if (data.containsKey('package_index')) {
      context.handle(
        _packageIndexMeta,
        packageIndex.isAcceptableOrUnknown(
          data['package_index']!,
          _packageIndexMeta,
        ),
      );
    }
    if (data.containsKey('source_status')) {
      context.handle(
        _sourceStatusMeta,
        sourceStatus.isAcceptableOrUnknown(
          data['source_status']!,
          _sourceStatusMeta,
        ),
      );
    }
    if (data.containsKey('original_fields_json')) {
      context.handle(
        _originalFieldsJsonMeta,
        originalFieldsJson.isAcceptableOrUnknown(
          data['original_fields_json']!,
          _originalFieldsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseSourceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      termKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_key'],
      )!,
      termCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_course_id'],
      )!,
      offeringId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offering_id'],
      )!,
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      packageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}package_index'],
      )!,
      sourceStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_status'],
      )!,
      originalFieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_fields_json'],
      )!,
    );
  }

  @override
  $CourseSourceRowsTable createAlias(String alias) {
    return $CourseSourceRowsTable(attachedDatabase, alias);
  }
}

class CourseSourceRow extends DataClass implements Insertable<CourseSourceRow> {
  final String id;
  final String termKey;
  final String termCourseId;
  final String offeringId;
  final String sourceKey;
  final int packageIndex;
  final String sourceStatus;
  final String originalFieldsJson;
  const CourseSourceRow({
    required this.id,
    required this.termKey,
    required this.termCourseId,
    required this.offeringId,
    required this.sourceKey,
    required this.packageIndex,
    required this.sourceStatus,
    required this.originalFieldsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['term_key'] = Variable<String>(termKey);
    map['term_course_id'] = Variable<String>(termCourseId);
    map['offering_id'] = Variable<String>(offeringId);
    map['source_key'] = Variable<String>(sourceKey);
    map['package_index'] = Variable<int>(packageIndex);
    map['source_status'] = Variable<String>(sourceStatus);
    map['original_fields_json'] = Variable<String>(originalFieldsJson);
    return map;
  }

  CourseSourceRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseSourceRowsCompanion(
      id: Value(id),
      termKey: Value(termKey),
      termCourseId: Value(termCourseId),
      offeringId: Value(offeringId),
      sourceKey: Value(sourceKey),
      packageIndex: Value(packageIndex),
      sourceStatus: Value(sourceStatus),
      originalFieldsJson: Value(originalFieldsJson),
    );
  }

  factory CourseSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseSourceRow(
      id: serializer.fromJson<String>(json['id']),
      termKey: serializer.fromJson<String>(json['termKey']),
      termCourseId: serializer.fromJson<String>(json['termCourseId']),
      offeringId: serializer.fromJson<String>(json['offeringId']),
      sourceKey: serializer.fromJson<String>(json['sourceKey']),
      packageIndex: serializer.fromJson<int>(json['packageIndex']),
      sourceStatus: serializer.fromJson<String>(json['sourceStatus']),
      originalFieldsJson: serializer.fromJson<String>(
        json['originalFieldsJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'termKey': serializer.toJson<String>(termKey),
      'termCourseId': serializer.toJson<String>(termCourseId),
      'offeringId': serializer.toJson<String>(offeringId),
      'sourceKey': serializer.toJson<String>(sourceKey),
      'packageIndex': serializer.toJson<int>(packageIndex),
      'sourceStatus': serializer.toJson<String>(sourceStatus),
      'originalFieldsJson': serializer.toJson<String>(originalFieldsJson),
    };
  }

  CourseSourceRow copyWith({
    String? id,
    String? termKey,
    String? termCourseId,
    String? offeringId,
    String? sourceKey,
    int? packageIndex,
    String? sourceStatus,
    String? originalFieldsJson,
  }) => CourseSourceRow(
    id: id ?? this.id,
    termKey: termKey ?? this.termKey,
    termCourseId: termCourseId ?? this.termCourseId,
    offeringId: offeringId ?? this.offeringId,
    sourceKey: sourceKey ?? this.sourceKey,
    packageIndex: packageIndex ?? this.packageIndex,
    sourceStatus: sourceStatus ?? this.sourceStatus,
    originalFieldsJson: originalFieldsJson ?? this.originalFieldsJson,
  );
  CourseSourceRow copyWithCompanion(CourseSourceRowsCompanion data) {
    return CourseSourceRow(
      id: data.id.present ? data.id.value : this.id,
      termKey: data.termKey.present ? data.termKey.value : this.termKey,
      termCourseId: data.termCourseId.present
          ? data.termCourseId.value
          : this.termCourseId,
      offeringId: data.offeringId.present
          ? data.offeringId.value
          : this.offeringId,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      packageIndex: data.packageIndex.present
          ? data.packageIndex.value
          : this.packageIndex,
      sourceStatus: data.sourceStatus.present
          ? data.sourceStatus.value
          : this.sourceStatus,
      originalFieldsJson: data.originalFieldsJson.present
          ? data.originalFieldsJson.value
          : this.originalFieldsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseSourceRow(')
          ..write('id: $id, ')
          ..write('termKey: $termKey, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('offeringId: $offeringId, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('packageIndex: $packageIndex, ')
          ..write('sourceStatus: $sourceStatus, ')
          ..write('originalFieldsJson: $originalFieldsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    termKey,
    termCourseId,
    offeringId,
    sourceKey,
    packageIndex,
    sourceStatus,
    originalFieldsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseSourceRow &&
          other.id == this.id &&
          other.termKey == this.termKey &&
          other.termCourseId == this.termCourseId &&
          other.offeringId == this.offeringId &&
          other.sourceKey == this.sourceKey &&
          other.packageIndex == this.packageIndex &&
          other.sourceStatus == this.sourceStatus &&
          other.originalFieldsJson == this.originalFieldsJson);
}

class CourseSourceRowsCompanion extends UpdateCompanion<CourseSourceRow> {
  final Value<String> id;
  final Value<String> termKey;
  final Value<String> termCourseId;
  final Value<String> offeringId;
  final Value<String> sourceKey;
  final Value<int> packageIndex;
  final Value<String> sourceStatus;
  final Value<String> originalFieldsJson;
  final Value<int> rowid;
  const CourseSourceRowsCompanion({
    this.id = const Value.absent(),
    this.termKey = const Value.absent(),
    this.termCourseId = const Value.absent(),
    this.offeringId = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.packageIndex = const Value.absent(),
    this.sourceStatus = const Value.absent(),
    this.originalFieldsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseSourceRowsCompanion.insert({
    required String id,
    required String termKey,
    this.termCourseId = const Value.absent(),
    this.offeringId = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.packageIndex = const Value.absent(),
    this.sourceStatus = const Value.absent(),
    this.originalFieldsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       termKey = Value(termKey);
  static Insertable<CourseSourceRow> custom({
    Expression<String>? id,
    Expression<String>? termKey,
    Expression<String>? termCourseId,
    Expression<String>? offeringId,
    Expression<String>? sourceKey,
    Expression<int>? packageIndex,
    Expression<String>? sourceStatus,
    Expression<String>? originalFieldsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (termKey != null) 'term_key': termKey,
      if (termCourseId != null) 'term_course_id': termCourseId,
      if (offeringId != null) 'offering_id': offeringId,
      if (sourceKey != null) 'source_key': sourceKey,
      if (packageIndex != null) 'package_index': packageIndex,
      if (sourceStatus != null) 'source_status': sourceStatus,
      if (originalFieldsJson != null)
        'original_fields_json': originalFieldsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseSourceRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? termKey,
    Value<String>? termCourseId,
    Value<String>? offeringId,
    Value<String>? sourceKey,
    Value<int>? packageIndex,
    Value<String>? sourceStatus,
    Value<String>? originalFieldsJson,
    Value<int>? rowid,
  }) {
    return CourseSourceRowsCompanion(
      id: id ?? this.id,
      termKey: termKey ?? this.termKey,
      termCourseId: termCourseId ?? this.termCourseId,
      offeringId: offeringId ?? this.offeringId,
      sourceKey: sourceKey ?? this.sourceKey,
      packageIndex: packageIndex ?? this.packageIndex,
      sourceStatus: sourceStatus ?? this.sourceStatus,
      originalFieldsJson: originalFieldsJson ?? this.originalFieldsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (termKey.present) {
      map['term_key'] = Variable<String>(termKey.value);
    }
    if (termCourseId.present) {
      map['term_course_id'] = Variable<String>(termCourseId.value);
    }
    if (offeringId.present) {
      map['offering_id'] = Variable<String>(offeringId.value);
    }
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (packageIndex.present) {
      map['package_index'] = Variable<int>(packageIndex.value);
    }
    if (sourceStatus.present) {
      map['source_status'] = Variable<String>(sourceStatus.value);
    }
    if (originalFieldsJson.present) {
      map['original_fields_json'] = Variable<String>(originalFieldsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseSourceRowsCompanion(')
          ..write('id: $id, ')
          ..write('termKey: $termKey, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('offeringId: $offeringId, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('packageIndex: $packageIndex, ')
          ..write('sourceStatus: $sourceStatus, ')
          ..write('originalFieldsJson: $originalFieldsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseMeetingRuleRowsTable extends CourseMeetingRuleRows
    with TableInfo<$CourseMeetingRuleRowsTable, CourseMeetingRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseMeetingRuleRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _offeringIdMeta = const VerificationMeta(
    'offeringId',
  );
  @override
  late final GeneratedColumn<String> offeringId = GeneratedColumn<String>(
    'offering_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_offering_rows (id)',
    ),
  );
  static const VerificationMeta _termKeyMeta = const VerificationMeta(
    'termKey',
  );
  @override
  late final GeneratedColumn<String> termKey = GeneratedColumn<String>(
    'term_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES school_timetable_term_rows (term_key)',
    ),
  );
  static const VerificationMeta _termCourseIdMeta = const VerificationMeta(
    'termCourseId',
  );
  @override
  late final GeneratedColumn<String> termCourseId = GeneratedColumn<String>(
    'term_course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_term_course_rows (id)',
    ),
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_catalog_rows (id)',
    ),
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentIndexMeta = const VerificationMeta(
    'segmentIndex',
  );
  @override
  late final GeneratedColumn<int> segmentIndex = GeneratedColumn<int>(
    'segment_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayLabelMeta = const VerificationMeta(
    'weekdayLabel',
  );
  @override
  late final GeneratedColumn<String> weekdayLabel = GeneratedColumn<String>(
    'weekday_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _weekTextMeta = const VerificationMeta(
    'weekText',
  );
  @override
  late final GeneratedColumn<String> weekText = GeneratedColumn<String>(
    'week_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sectionTextMeta = const VerificationMeta(
    'sectionText',
  );
  @override
  late final GeneratedColumn<String> sectionText = GeneratedColumn<String>(
    'section_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locationTextMeta = const VerificationMeta(
    'locationText',
  );
  @override
  late final GeneratedColumn<String> locationText = GeneratedColumn<String>(
    'location_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _buildingMeta = const VerificationMeta(
    'building',
  );
  @override
  late final GeneratedColumn<String> building = GeneratedColumn<String>(
    'building',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    offeringId,
    termKey,
    termCourseId,
    catalogId,
    weekday,
    segmentIndex,
    weekdayLabel,
    rawText,
    weekText,
    sectionText,
    locationText,
    building,
    room,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_meeting_rule_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseMeetingRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('offering_id')) {
      context.handle(
        _offeringIdMeta,
        offeringId.isAcceptableOrUnknown(data['offering_id']!, _offeringIdMeta),
      );
    } else if (isInserting) {
      context.missing(_offeringIdMeta);
    }
    if (data.containsKey('term_key')) {
      context.handle(
        _termKeyMeta,
        termKey.isAcceptableOrUnknown(data['term_key']!, _termKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_termKeyMeta);
    }
    if (data.containsKey('term_course_id')) {
      context.handle(
        _termCourseIdMeta,
        termCourseId.isAcceptableOrUnknown(
          data['term_course_id']!,
          _termCourseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_termCourseIdMeta);
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('segment_index')) {
      context.handle(
        _segmentIndexMeta,
        segmentIndex.isAcceptableOrUnknown(
          data['segment_index']!,
          _segmentIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentIndexMeta);
    }
    if (data.containsKey('weekday_label')) {
      context.handle(
        _weekdayLabelMeta,
        weekdayLabel.isAcceptableOrUnknown(
          data['weekday_label']!,
          _weekdayLabelMeta,
        ),
      );
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    if (data.containsKey('week_text')) {
      context.handle(
        _weekTextMeta,
        weekText.isAcceptableOrUnknown(data['week_text']!, _weekTextMeta),
      );
    }
    if (data.containsKey('section_text')) {
      context.handle(
        _sectionTextMeta,
        sectionText.isAcceptableOrUnknown(
          data['section_text']!,
          _sectionTextMeta,
        ),
      );
    }
    if (data.containsKey('location_text')) {
      context.handle(
        _locationTextMeta,
        locationText.isAcceptableOrUnknown(
          data['location_text']!,
          _locationTextMeta,
        ),
      );
    }
    if (data.containsKey('building')) {
      context.handle(
        _buildingMeta,
        building.isAcceptableOrUnknown(data['building']!, _buildingMeta),
      );
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseMeetingRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseMeetingRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      offeringId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offering_id'],
      )!,
      termKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_key'],
      )!,
      termCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_course_id'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      segmentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_index'],
      )!,
      weekdayLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekday_label'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      weekText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_text'],
      )!,
      sectionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_text'],
      )!,
      locationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_text'],
      )!,
      building: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building'],
      )!,
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      )!,
    );
  }

  @override
  $CourseMeetingRuleRowsTable createAlias(String alias) {
    return $CourseMeetingRuleRowsTable(attachedDatabase, alias);
  }
}

class CourseMeetingRuleRow extends DataClass
    implements Insertable<CourseMeetingRuleRow> {
  final String id;
  final String offeringId;
  final String termKey;
  final String termCourseId;
  final String catalogId;
  final int weekday;
  final int segmentIndex;
  final String weekdayLabel;
  final String rawText;
  final String weekText;
  final String sectionText;
  final String locationText;
  final String building;
  final String room;
  const CourseMeetingRuleRow({
    required this.id,
    required this.offeringId,
    required this.termKey,
    required this.termCourseId,
    required this.catalogId,
    required this.weekday,
    required this.segmentIndex,
    required this.weekdayLabel,
    required this.rawText,
    required this.weekText,
    required this.sectionText,
    required this.locationText,
    required this.building,
    required this.room,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['offering_id'] = Variable<String>(offeringId);
    map['term_key'] = Variable<String>(termKey);
    map['term_course_id'] = Variable<String>(termCourseId);
    map['catalog_id'] = Variable<String>(catalogId);
    map['weekday'] = Variable<int>(weekday);
    map['segment_index'] = Variable<int>(segmentIndex);
    map['weekday_label'] = Variable<String>(weekdayLabel);
    map['raw_text'] = Variable<String>(rawText);
    map['week_text'] = Variable<String>(weekText);
    map['section_text'] = Variable<String>(sectionText);
    map['location_text'] = Variable<String>(locationText);
    map['building'] = Variable<String>(building);
    map['room'] = Variable<String>(room);
    return map;
  }

  CourseMeetingRuleRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseMeetingRuleRowsCompanion(
      id: Value(id),
      offeringId: Value(offeringId),
      termKey: Value(termKey),
      termCourseId: Value(termCourseId),
      catalogId: Value(catalogId),
      weekday: Value(weekday),
      segmentIndex: Value(segmentIndex),
      weekdayLabel: Value(weekdayLabel),
      rawText: Value(rawText),
      weekText: Value(weekText),
      sectionText: Value(sectionText),
      locationText: Value(locationText),
      building: Value(building),
      room: Value(room),
    );
  }

  factory CourseMeetingRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseMeetingRuleRow(
      id: serializer.fromJson<String>(json['id']),
      offeringId: serializer.fromJson<String>(json['offeringId']),
      termKey: serializer.fromJson<String>(json['termKey']),
      termCourseId: serializer.fromJson<String>(json['termCourseId']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      weekday: serializer.fromJson<int>(json['weekday']),
      segmentIndex: serializer.fromJson<int>(json['segmentIndex']),
      weekdayLabel: serializer.fromJson<String>(json['weekdayLabel']),
      rawText: serializer.fromJson<String>(json['rawText']),
      weekText: serializer.fromJson<String>(json['weekText']),
      sectionText: serializer.fromJson<String>(json['sectionText']),
      locationText: serializer.fromJson<String>(json['locationText']),
      building: serializer.fromJson<String>(json['building']),
      room: serializer.fromJson<String>(json['room']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'offeringId': serializer.toJson<String>(offeringId),
      'termKey': serializer.toJson<String>(termKey),
      'termCourseId': serializer.toJson<String>(termCourseId),
      'catalogId': serializer.toJson<String>(catalogId),
      'weekday': serializer.toJson<int>(weekday),
      'segmentIndex': serializer.toJson<int>(segmentIndex),
      'weekdayLabel': serializer.toJson<String>(weekdayLabel),
      'rawText': serializer.toJson<String>(rawText),
      'weekText': serializer.toJson<String>(weekText),
      'sectionText': serializer.toJson<String>(sectionText),
      'locationText': serializer.toJson<String>(locationText),
      'building': serializer.toJson<String>(building),
      'room': serializer.toJson<String>(room),
    };
  }

  CourseMeetingRuleRow copyWith({
    String? id,
    String? offeringId,
    String? termKey,
    String? termCourseId,
    String? catalogId,
    int? weekday,
    int? segmentIndex,
    String? weekdayLabel,
    String? rawText,
    String? weekText,
    String? sectionText,
    String? locationText,
    String? building,
    String? room,
  }) => CourseMeetingRuleRow(
    id: id ?? this.id,
    offeringId: offeringId ?? this.offeringId,
    termKey: termKey ?? this.termKey,
    termCourseId: termCourseId ?? this.termCourseId,
    catalogId: catalogId ?? this.catalogId,
    weekday: weekday ?? this.weekday,
    segmentIndex: segmentIndex ?? this.segmentIndex,
    weekdayLabel: weekdayLabel ?? this.weekdayLabel,
    rawText: rawText ?? this.rawText,
    weekText: weekText ?? this.weekText,
    sectionText: sectionText ?? this.sectionText,
    locationText: locationText ?? this.locationText,
    building: building ?? this.building,
    room: room ?? this.room,
  );
  CourseMeetingRuleRow copyWithCompanion(CourseMeetingRuleRowsCompanion data) {
    return CourseMeetingRuleRow(
      id: data.id.present ? data.id.value : this.id,
      offeringId: data.offeringId.present
          ? data.offeringId.value
          : this.offeringId,
      termKey: data.termKey.present ? data.termKey.value : this.termKey,
      termCourseId: data.termCourseId.present
          ? data.termCourseId.value
          : this.termCourseId,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      segmentIndex: data.segmentIndex.present
          ? data.segmentIndex.value
          : this.segmentIndex,
      weekdayLabel: data.weekdayLabel.present
          ? data.weekdayLabel.value
          : this.weekdayLabel,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      weekText: data.weekText.present ? data.weekText.value : this.weekText,
      sectionText: data.sectionText.present
          ? data.sectionText.value
          : this.sectionText,
      locationText: data.locationText.present
          ? data.locationText.value
          : this.locationText,
      building: data.building.present ? data.building.value : this.building,
      room: data.room.present ? data.room.value : this.room,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseMeetingRuleRow(')
          ..write('id: $id, ')
          ..write('offeringId: $offeringId, ')
          ..write('termKey: $termKey, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('catalogId: $catalogId, ')
          ..write('weekday: $weekday, ')
          ..write('segmentIndex: $segmentIndex, ')
          ..write('weekdayLabel: $weekdayLabel, ')
          ..write('rawText: $rawText, ')
          ..write('weekText: $weekText, ')
          ..write('sectionText: $sectionText, ')
          ..write('locationText: $locationText, ')
          ..write('building: $building, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    offeringId,
    termKey,
    termCourseId,
    catalogId,
    weekday,
    segmentIndex,
    weekdayLabel,
    rawText,
    weekText,
    sectionText,
    locationText,
    building,
    room,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseMeetingRuleRow &&
          other.id == this.id &&
          other.offeringId == this.offeringId &&
          other.termKey == this.termKey &&
          other.termCourseId == this.termCourseId &&
          other.catalogId == this.catalogId &&
          other.weekday == this.weekday &&
          other.segmentIndex == this.segmentIndex &&
          other.weekdayLabel == this.weekdayLabel &&
          other.rawText == this.rawText &&
          other.weekText == this.weekText &&
          other.sectionText == this.sectionText &&
          other.locationText == this.locationText &&
          other.building == this.building &&
          other.room == this.room);
}

class CourseMeetingRuleRowsCompanion
    extends UpdateCompanion<CourseMeetingRuleRow> {
  final Value<String> id;
  final Value<String> offeringId;
  final Value<String> termKey;
  final Value<String> termCourseId;
  final Value<String> catalogId;
  final Value<int> weekday;
  final Value<int> segmentIndex;
  final Value<String> weekdayLabel;
  final Value<String> rawText;
  final Value<String> weekText;
  final Value<String> sectionText;
  final Value<String> locationText;
  final Value<String> building;
  final Value<String> room;
  final Value<int> rowid;
  const CourseMeetingRuleRowsCompanion({
    this.id = const Value.absent(),
    this.offeringId = const Value.absent(),
    this.termKey = const Value.absent(),
    this.termCourseId = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.weekday = const Value.absent(),
    this.segmentIndex = const Value.absent(),
    this.weekdayLabel = const Value.absent(),
    this.rawText = const Value.absent(),
    this.weekText = const Value.absent(),
    this.sectionText = const Value.absent(),
    this.locationText = const Value.absent(),
    this.building = const Value.absent(),
    this.room = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseMeetingRuleRowsCompanion.insert({
    required String id,
    required String offeringId,
    required String termKey,
    required String termCourseId,
    required String catalogId,
    required int weekday,
    required int segmentIndex,
    this.weekdayLabel = const Value.absent(),
    this.rawText = const Value.absent(),
    this.weekText = const Value.absent(),
    this.sectionText = const Value.absent(),
    this.locationText = const Value.absent(),
    this.building = const Value.absent(),
    this.room = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       offeringId = Value(offeringId),
       termKey = Value(termKey),
       termCourseId = Value(termCourseId),
       catalogId = Value(catalogId),
       weekday = Value(weekday),
       segmentIndex = Value(segmentIndex);
  static Insertable<CourseMeetingRuleRow> custom({
    Expression<String>? id,
    Expression<String>? offeringId,
    Expression<String>? termKey,
    Expression<String>? termCourseId,
    Expression<String>? catalogId,
    Expression<int>? weekday,
    Expression<int>? segmentIndex,
    Expression<String>? weekdayLabel,
    Expression<String>? rawText,
    Expression<String>? weekText,
    Expression<String>? sectionText,
    Expression<String>? locationText,
    Expression<String>? building,
    Expression<String>? room,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (offeringId != null) 'offering_id': offeringId,
      if (termKey != null) 'term_key': termKey,
      if (termCourseId != null) 'term_course_id': termCourseId,
      if (catalogId != null) 'catalog_id': catalogId,
      if (weekday != null) 'weekday': weekday,
      if (segmentIndex != null) 'segment_index': segmentIndex,
      if (weekdayLabel != null) 'weekday_label': weekdayLabel,
      if (rawText != null) 'raw_text': rawText,
      if (weekText != null) 'week_text': weekText,
      if (sectionText != null) 'section_text': sectionText,
      if (locationText != null) 'location_text': locationText,
      if (building != null) 'building': building,
      if (room != null) 'room': room,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseMeetingRuleRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? offeringId,
    Value<String>? termKey,
    Value<String>? termCourseId,
    Value<String>? catalogId,
    Value<int>? weekday,
    Value<int>? segmentIndex,
    Value<String>? weekdayLabel,
    Value<String>? rawText,
    Value<String>? weekText,
    Value<String>? sectionText,
    Value<String>? locationText,
    Value<String>? building,
    Value<String>? room,
    Value<int>? rowid,
  }) {
    return CourseMeetingRuleRowsCompanion(
      id: id ?? this.id,
      offeringId: offeringId ?? this.offeringId,
      termKey: termKey ?? this.termKey,
      termCourseId: termCourseId ?? this.termCourseId,
      catalogId: catalogId ?? this.catalogId,
      weekday: weekday ?? this.weekday,
      segmentIndex: segmentIndex ?? this.segmentIndex,
      weekdayLabel: weekdayLabel ?? this.weekdayLabel,
      rawText: rawText ?? this.rawText,
      weekText: weekText ?? this.weekText,
      sectionText: sectionText ?? this.sectionText,
      locationText: locationText ?? this.locationText,
      building: building ?? this.building,
      room: room ?? this.room,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (offeringId.present) {
      map['offering_id'] = Variable<String>(offeringId.value);
    }
    if (termKey.present) {
      map['term_key'] = Variable<String>(termKey.value);
    }
    if (termCourseId.present) {
      map['term_course_id'] = Variable<String>(termCourseId.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (segmentIndex.present) {
      map['segment_index'] = Variable<int>(segmentIndex.value);
    }
    if (weekdayLabel.present) {
      map['weekday_label'] = Variable<String>(weekdayLabel.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (weekText.present) {
      map['week_text'] = Variable<String>(weekText.value);
    }
    if (sectionText.present) {
      map['section_text'] = Variable<String>(sectionText.value);
    }
    if (locationText.present) {
      map['location_text'] = Variable<String>(locationText.value);
    }
    if (building.present) {
      map['building'] = Variable<String>(building.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseMeetingRuleRowsCompanion(')
          ..write('id: $id, ')
          ..write('offeringId: $offeringId, ')
          ..write('termKey: $termKey, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('catalogId: $catalogId, ')
          ..write('weekday: $weekday, ')
          ..write('segmentIndex: $segmentIndex, ')
          ..write('weekdayLabel: $weekdayLabel, ')
          ..write('rawText: $rawText, ')
          ..write('weekText: $weekText, ')
          ..write('sectionText: $sectionText, ')
          ..write('locationText: $locationText, ')
          ..write('building: $building, ')
          ..write('room: $room, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseOccurrenceRowsTable extends CourseOccurrenceRows
    with TableInfo<$CourseOccurrenceRowsTable, CourseOccurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseOccurrenceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_meeting_rule_rows (id)',
    ),
  );
  static const VerificationMeta _offeringIdMeta = const VerificationMeta(
    'offeringId',
  );
  @override
  late final GeneratedColumn<String> offeringId = GeneratedColumn<String>(
    'offering_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_offering_rows (id)',
    ),
  );
  static const VerificationMeta _termKeyMeta = const VerificationMeta(
    'termKey',
  );
  @override
  late final GeneratedColumn<String> termKey = GeneratedColumn<String>(
    'term_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES school_timetable_term_rows (term_key)',
    ),
  );
  static const VerificationMeta _termCourseIdMeta = const VerificationMeta(
    'termCourseId',
  );
  @override
  late final GeneratedColumn<String> termCourseId = GeneratedColumn<String>(
    'term_course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_term_course_rows (id)',
    ),
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_catalog_rows (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekIndexMeta = const VerificationMeta(
    'weekIndex',
  );
  @override
  late final GeneratedColumn<int> weekIndex = GeneratedColumn<int>(
    'week_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionTextMeta = const VerificationMeta(
    'sectionText',
  );
  @override
  late final GeneratedColumn<String> sectionText = GeneratedColumn<String>(
    'section_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locationTextMeta = const VerificationMeta(
    'locationText',
  );
  @override
  late final GeneratedColumn<String> locationText = GeneratedColumn<String>(
    'location_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _buildingMeta = const VerificationMeta(
    'building',
  );
  @override
  late final GeneratedColumn<String> building = GeneratedColumn<String>(
    'building',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ruleId,
    offeringId,
    termKey,
    termCourseId,
    catalogId,
    date,
    weekIndex,
    weekday,
    sectionText,
    locationText,
    building,
    room,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_occurrence_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseOccurrenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('offering_id')) {
      context.handle(
        _offeringIdMeta,
        offeringId.isAcceptableOrUnknown(data['offering_id']!, _offeringIdMeta),
      );
    } else if (isInserting) {
      context.missing(_offeringIdMeta);
    }
    if (data.containsKey('term_key')) {
      context.handle(
        _termKeyMeta,
        termKey.isAcceptableOrUnknown(data['term_key']!, _termKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_termKeyMeta);
    }
    if (data.containsKey('term_course_id')) {
      context.handle(
        _termCourseIdMeta,
        termCourseId.isAcceptableOrUnknown(
          data['term_course_id']!,
          _termCourseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_termCourseIdMeta);
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('week_index')) {
      context.handle(
        _weekIndexMeta,
        weekIndex.isAcceptableOrUnknown(data['week_index']!, _weekIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_weekIndexMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('section_text')) {
      context.handle(
        _sectionTextMeta,
        sectionText.isAcceptableOrUnknown(
          data['section_text']!,
          _sectionTextMeta,
        ),
      );
    }
    if (data.containsKey('location_text')) {
      context.handle(
        _locationTextMeta,
        locationText.isAcceptableOrUnknown(
          data['location_text']!,
          _locationTextMeta,
        ),
      );
    }
    if (data.containsKey('building')) {
      context.handle(
        _buildingMeta,
        building.isAcceptableOrUnknown(data['building']!, _buildingMeta),
      );
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseOccurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseOccurrenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      offeringId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offering_id'],
      )!,
      termKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_key'],
      )!,
      termCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_course_id'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      weekIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_index'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      sectionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_text'],
      )!,
      locationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_text'],
      )!,
      building: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building'],
      )!,
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      )!,
    );
  }

  @override
  $CourseOccurrenceRowsTable createAlias(String alias) {
    return $CourseOccurrenceRowsTable(attachedDatabase, alias);
  }
}

class CourseOccurrenceRow extends DataClass
    implements Insertable<CourseOccurrenceRow> {
  final String id;
  final String ruleId;
  final String offeringId;
  final String termKey;
  final String termCourseId;
  final String catalogId;
  final String date;
  final int weekIndex;
  final int weekday;
  final String sectionText;
  final String locationText;
  final String building;
  final String room;
  const CourseOccurrenceRow({
    required this.id,
    required this.ruleId,
    required this.offeringId,
    required this.termKey,
    required this.termCourseId,
    required this.catalogId,
    required this.date,
    required this.weekIndex,
    required this.weekday,
    required this.sectionText,
    required this.locationText,
    required this.building,
    required this.room,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rule_id'] = Variable<String>(ruleId);
    map['offering_id'] = Variable<String>(offeringId);
    map['term_key'] = Variable<String>(termKey);
    map['term_course_id'] = Variable<String>(termCourseId);
    map['catalog_id'] = Variable<String>(catalogId);
    map['date'] = Variable<String>(date);
    map['week_index'] = Variable<int>(weekIndex);
    map['weekday'] = Variable<int>(weekday);
    map['section_text'] = Variable<String>(sectionText);
    map['location_text'] = Variable<String>(locationText);
    map['building'] = Variable<String>(building);
    map['room'] = Variable<String>(room);
    return map;
  }

  CourseOccurrenceRowsCompanion toCompanion(bool nullToAbsent) {
    return CourseOccurrenceRowsCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      offeringId: Value(offeringId),
      termKey: Value(termKey),
      termCourseId: Value(termCourseId),
      catalogId: Value(catalogId),
      date: Value(date),
      weekIndex: Value(weekIndex),
      weekday: Value(weekday),
      sectionText: Value(sectionText),
      locationText: Value(locationText),
      building: Value(building),
      room: Value(room),
    );
  }

  factory CourseOccurrenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseOccurrenceRow(
      id: serializer.fromJson<String>(json['id']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      offeringId: serializer.fromJson<String>(json['offeringId']),
      termKey: serializer.fromJson<String>(json['termKey']),
      termCourseId: serializer.fromJson<String>(json['termCourseId']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      date: serializer.fromJson<String>(json['date']),
      weekIndex: serializer.fromJson<int>(json['weekIndex']),
      weekday: serializer.fromJson<int>(json['weekday']),
      sectionText: serializer.fromJson<String>(json['sectionText']),
      locationText: serializer.fromJson<String>(json['locationText']),
      building: serializer.fromJson<String>(json['building']),
      room: serializer.fromJson<String>(json['room']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ruleId': serializer.toJson<String>(ruleId),
      'offeringId': serializer.toJson<String>(offeringId),
      'termKey': serializer.toJson<String>(termKey),
      'termCourseId': serializer.toJson<String>(termCourseId),
      'catalogId': serializer.toJson<String>(catalogId),
      'date': serializer.toJson<String>(date),
      'weekIndex': serializer.toJson<int>(weekIndex),
      'weekday': serializer.toJson<int>(weekday),
      'sectionText': serializer.toJson<String>(sectionText),
      'locationText': serializer.toJson<String>(locationText),
      'building': serializer.toJson<String>(building),
      'room': serializer.toJson<String>(room),
    };
  }

  CourseOccurrenceRow copyWith({
    String? id,
    String? ruleId,
    String? offeringId,
    String? termKey,
    String? termCourseId,
    String? catalogId,
    String? date,
    int? weekIndex,
    int? weekday,
    String? sectionText,
    String? locationText,
    String? building,
    String? room,
  }) => CourseOccurrenceRow(
    id: id ?? this.id,
    ruleId: ruleId ?? this.ruleId,
    offeringId: offeringId ?? this.offeringId,
    termKey: termKey ?? this.termKey,
    termCourseId: termCourseId ?? this.termCourseId,
    catalogId: catalogId ?? this.catalogId,
    date: date ?? this.date,
    weekIndex: weekIndex ?? this.weekIndex,
    weekday: weekday ?? this.weekday,
    sectionText: sectionText ?? this.sectionText,
    locationText: locationText ?? this.locationText,
    building: building ?? this.building,
    room: room ?? this.room,
  );
  CourseOccurrenceRow copyWithCompanion(CourseOccurrenceRowsCompanion data) {
    return CourseOccurrenceRow(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      offeringId: data.offeringId.present
          ? data.offeringId.value
          : this.offeringId,
      termKey: data.termKey.present ? data.termKey.value : this.termKey,
      termCourseId: data.termCourseId.present
          ? data.termCourseId.value
          : this.termCourseId,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      date: data.date.present ? data.date.value : this.date,
      weekIndex: data.weekIndex.present ? data.weekIndex.value : this.weekIndex,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      sectionText: data.sectionText.present
          ? data.sectionText.value
          : this.sectionText,
      locationText: data.locationText.present
          ? data.locationText.value
          : this.locationText,
      building: data.building.present ? data.building.value : this.building,
      room: data.room.present ? data.room.value : this.room,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseOccurrenceRow(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('offeringId: $offeringId, ')
          ..write('termKey: $termKey, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('catalogId: $catalogId, ')
          ..write('date: $date, ')
          ..write('weekIndex: $weekIndex, ')
          ..write('weekday: $weekday, ')
          ..write('sectionText: $sectionText, ')
          ..write('locationText: $locationText, ')
          ..write('building: $building, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ruleId,
    offeringId,
    termKey,
    termCourseId,
    catalogId,
    date,
    weekIndex,
    weekday,
    sectionText,
    locationText,
    building,
    room,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseOccurrenceRow &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.offeringId == this.offeringId &&
          other.termKey == this.termKey &&
          other.termCourseId == this.termCourseId &&
          other.catalogId == this.catalogId &&
          other.date == this.date &&
          other.weekIndex == this.weekIndex &&
          other.weekday == this.weekday &&
          other.sectionText == this.sectionText &&
          other.locationText == this.locationText &&
          other.building == this.building &&
          other.room == this.room);
}

class CourseOccurrenceRowsCompanion
    extends UpdateCompanion<CourseOccurrenceRow> {
  final Value<String> id;
  final Value<String> ruleId;
  final Value<String> offeringId;
  final Value<String> termKey;
  final Value<String> termCourseId;
  final Value<String> catalogId;
  final Value<String> date;
  final Value<int> weekIndex;
  final Value<int> weekday;
  final Value<String> sectionText;
  final Value<String> locationText;
  final Value<String> building;
  final Value<String> room;
  final Value<int> rowid;
  const CourseOccurrenceRowsCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.offeringId = const Value.absent(),
    this.termKey = const Value.absent(),
    this.termCourseId = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.date = const Value.absent(),
    this.weekIndex = const Value.absent(),
    this.weekday = const Value.absent(),
    this.sectionText = const Value.absent(),
    this.locationText = const Value.absent(),
    this.building = const Value.absent(),
    this.room = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseOccurrenceRowsCompanion.insert({
    required String id,
    required String ruleId,
    required String offeringId,
    required String termKey,
    required String termCourseId,
    required String catalogId,
    required String date,
    required int weekIndex,
    required int weekday,
    this.sectionText = const Value.absent(),
    this.locationText = const Value.absent(),
    this.building = const Value.absent(),
    this.room = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ruleId = Value(ruleId),
       offeringId = Value(offeringId),
       termKey = Value(termKey),
       termCourseId = Value(termCourseId),
       catalogId = Value(catalogId),
       date = Value(date),
       weekIndex = Value(weekIndex),
       weekday = Value(weekday);
  static Insertable<CourseOccurrenceRow> custom({
    Expression<String>? id,
    Expression<String>? ruleId,
    Expression<String>? offeringId,
    Expression<String>? termKey,
    Expression<String>? termCourseId,
    Expression<String>? catalogId,
    Expression<String>? date,
    Expression<int>? weekIndex,
    Expression<int>? weekday,
    Expression<String>? sectionText,
    Expression<String>? locationText,
    Expression<String>? building,
    Expression<String>? room,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (offeringId != null) 'offering_id': offeringId,
      if (termKey != null) 'term_key': termKey,
      if (termCourseId != null) 'term_course_id': termCourseId,
      if (catalogId != null) 'catalog_id': catalogId,
      if (date != null) 'date': date,
      if (weekIndex != null) 'week_index': weekIndex,
      if (weekday != null) 'weekday': weekday,
      if (sectionText != null) 'section_text': sectionText,
      if (locationText != null) 'location_text': locationText,
      if (building != null) 'building': building,
      if (room != null) 'room': room,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseOccurrenceRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? ruleId,
    Value<String>? offeringId,
    Value<String>? termKey,
    Value<String>? termCourseId,
    Value<String>? catalogId,
    Value<String>? date,
    Value<int>? weekIndex,
    Value<int>? weekday,
    Value<String>? sectionText,
    Value<String>? locationText,
    Value<String>? building,
    Value<String>? room,
    Value<int>? rowid,
  }) {
    return CourseOccurrenceRowsCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      offeringId: offeringId ?? this.offeringId,
      termKey: termKey ?? this.termKey,
      termCourseId: termCourseId ?? this.termCourseId,
      catalogId: catalogId ?? this.catalogId,
      date: date ?? this.date,
      weekIndex: weekIndex ?? this.weekIndex,
      weekday: weekday ?? this.weekday,
      sectionText: sectionText ?? this.sectionText,
      locationText: locationText ?? this.locationText,
      building: building ?? this.building,
      room: room ?? this.room,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (offeringId.present) {
      map['offering_id'] = Variable<String>(offeringId.value);
    }
    if (termKey.present) {
      map['term_key'] = Variable<String>(termKey.value);
    }
    if (termCourseId.present) {
      map['term_course_id'] = Variable<String>(termCourseId.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (weekIndex.present) {
      map['week_index'] = Variable<int>(weekIndex.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (sectionText.present) {
      map['section_text'] = Variable<String>(sectionText.value);
    }
    if (locationText.present) {
      map['location_text'] = Variable<String>(locationText.value);
    }
    if (building.present) {
      map['building'] = Variable<String>(building.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseOccurrenceRowsCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('offeringId: $offeringId, ')
          ..write('termKey: $termKey, ')
          ..write('termCourseId: $termCourseId, ')
          ..write('catalogId: $catalogId, ')
          ..write('date: $date, ')
          ..write('weekIndex: $weekIndex, ')
          ..write('weekday: $weekday, ')
          ..write('sectionText: $sectionText, ')
          ..write('locationText: $locationText, ')
          ..write('building: $building, ')
          ..write('room: $room, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncTombstoneRowsTable extends SyncTombstoneRows
    with TableInfo<$SyncTombstoneRowsTable, SyncTombstoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncTombstoneRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    revision,
    dirty,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_tombstone_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncTombstoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  SyncTombstoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncTombstoneRow(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
    );
  }

  @override
  $SyncTombstoneRowsTable createAlias(String alias) {
    return $SyncTombstoneRowsTable(attachedDatabase, alias);
  }
}

class SyncTombstoneRow extends DataClass
    implements Insertable<SyncTombstoneRow> {
  final String entityType;
  final String entityId;
  final int revision;
  final bool dirty;
  final DateTime deletedAt;
  const SyncTombstoneRow({
    required this.entityType,
    required this.entityId,
    required this.revision,
    required this.dirty,
    required this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['revision'] = Variable<int>(revision);
    map['dirty'] = Variable<bool>(dirty);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  SyncTombstoneRowsCompanion toCompanion(bool nullToAbsent) {
    return SyncTombstoneRowsCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      revision: Value(revision),
      dirty: Value(dirty),
      deletedAt: Value(deletedAt),
    );
  }

  factory SyncTombstoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncTombstoneRow(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      revision: serializer.fromJson<int>(json['revision']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'revision': serializer.toJson<int>(revision),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  SyncTombstoneRow copyWith({
    String? entityType,
    String? entityId,
    int? revision,
    bool? dirty,
    DateTime? deletedAt,
  }) => SyncTombstoneRow(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    revision: revision ?? this.revision,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt ?? this.deletedAt,
  );
  SyncTombstoneRow copyWithCompanion(SyncTombstoneRowsCompanion data) {
    return SyncTombstoneRow(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      revision: data.revision.present ? data.revision.value : this.revision,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncTombstoneRow(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('revision: $revision, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entityType, entityId, revision, dirty, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncTombstoneRow &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.revision == this.revision &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt);
}

class SyncTombstoneRowsCompanion extends UpdateCompanion<SyncTombstoneRow> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<int> revision;
  final Value<bool> dirty;
  final Value<DateTime> deletedAt;
  final Value<int> rowid;
  const SyncTombstoneRowsCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.revision = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncTombstoneRowsCompanion.insert({
    required String entityType,
    required String entityId,
    this.revision = const Value.absent(),
    this.dirty = const Value.absent(),
    required DateTime deletedAt,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       deletedAt = Value(deletedAt);
  static Insertable<SyncTombstoneRow> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<int>? revision,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (revision != null) 'revision': revision,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncTombstoneRowsCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<int>? revision,
    Value<bool>? dirty,
    Value<DateTime>? deletedAt,
    Value<int>? rowid,
  }) {
    return SyncTombstoneRowsCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      revision: revision ?? this.revision,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncTombstoneRowsCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('revision: $revision, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AgendaItemRowsTable agendaItemRows = $AgendaItemRowsTable(this);
  late final $ScheduleItemDetailRowsTable scheduleItemDetailRows =
      $ScheduleItemDetailRowsTable(this);
  late final $TaskItemDetailRowsTable taskItemDetailRows =
      $TaskItemDetailRowsTable(this);
  late final $CourseItemDetailRowsTable courseItemDetailRows =
      $CourseItemDetailRowsTable(this);
  late final $CourseTimetableRowsTable courseTimetableRows =
      $CourseTimetableRowsTable(this);
  late final $SelectedCourseTimetableRowsTable selectedCourseTimetableRows =
      $SelectedCourseTimetableRowsTable(this);
  late final $SchoolTimetableTermRowsTable schoolTimetableTermRows =
      $SchoolTimetableTermRowsTable(this);
  late final $CourseCatalogRowsTable courseCatalogRows =
      $CourseCatalogRowsTable(this);
  late final $CourseTermCourseRowsTable courseTermCourseRows =
      $CourseTermCourseRowsTable(this);
  late final $CourseInstructorCourseRowsTable courseInstructorCourseRows =
      $CourseInstructorCourseRowsTable(this);
  late final $CourseOfferingRowsTable courseOfferingRows =
      $CourseOfferingRowsTable(this);
  late final $CourseAudienceRowsTable courseAudienceRows =
      $CourseAudienceRowsTable(this);
  late final $CourseSourceRowsTable courseSourceRows = $CourseSourceRowsTable(
    this,
  );
  late final $CourseMeetingRuleRowsTable courseMeetingRuleRows =
      $CourseMeetingRuleRowsTable(this);
  late final $CourseOccurrenceRowsTable courseOccurrenceRows =
      $CourseOccurrenceRowsTable(this);
  late final $SyncTombstoneRowsTable syncTombstoneRows =
      $SyncTombstoneRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    agendaItemRows,
    scheduleItemDetailRows,
    taskItemDetailRows,
    courseItemDetailRows,
    courseTimetableRows,
    selectedCourseTimetableRows,
    schoolTimetableTermRows,
    courseCatalogRows,
    courseTermCourseRows,
    courseInstructorCourseRows,
    courseOfferingRows,
    courseAudienceRows,
    courseSourceRows,
    courseMeetingRuleRows,
    courseOccurrenceRows,
    syncTombstoneRows,
  ];
}

typedef $$AgendaItemRowsTableCreateCompanionBuilder =
    AgendaItemRowsCompanion Function({
      required String id,
      required String type,
      required String title,
      Value<String> notes,
      Value<String> location,
      required String color,
      required String reminder,
      required String repeatRule,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<double> sortOrder,
      Value<String> sourceKind,
      Value<String> sourceRef,
      Value<String?> remoteId,
      Value<int> revision,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<DateTime?> lastSyncedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AgendaItemRowsTableUpdateCompanionBuilder =
    AgendaItemRowsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> title,
      Value<String> notes,
      Value<String> location,
      Value<String> color,
      Value<String> reminder,
      Value<String> repeatRule,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<double> sortOrder,
      Value<String> sourceKind,
      Value<String> sourceRef,
      Value<String?> remoteId,
      Value<int> revision,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$AgendaItemRowsTableReferences
    extends BaseReferences<_$AppDatabase, $AgendaItemRowsTable, AgendaItemRow> {
  $$AgendaItemRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ScheduleItemDetailRowsTable,
    List<ScheduleItemDetailRow>
  >
  _scheduleItemDetailRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduleItemDetailRows,
        aliasName: $_aliasNameGenerator(
          db.agendaItemRows.id,
          db.scheduleItemDetailRows.itemId,
        ),
      );

  $$ScheduleItemDetailRowsTableProcessedTableManager
  get scheduleItemDetailRowsRefs {
    final manager = $$ScheduleItemDetailRowsTableTableManager(
      $_db,
      $_db.scheduleItemDetailRows,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduleItemDetailRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TaskItemDetailRowsTable, List<TaskItemDetailRow>>
  _taskItemDetailRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.taskItemDetailRows,
        aliasName: $_aliasNameGenerator(
          db.agendaItemRows.id,
          db.taskItemDetailRows.itemId,
        ),
      );

  $$TaskItemDetailRowsTableProcessedTableManager get taskItemDetailRowsRefs {
    final manager = $$TaskItemDetailRowsTableTableManager(
      $_db,
      $_db.taskItemDetailRows,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _taskItemDetailRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CourseItemDetailRowsTable,
    List<CourseItemDetailRow>
  >
  _courseItemDetailRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseItemDetailRows,
        aliasName: $_aliasNameGenerator(
          db.agendaItemRows.id,
          db.courseItemDetailRows.itemId,
        ),
      );

  $$CourseItemDetailRowsTableProcessedTableManager
  get courseItemDetailRowsRefs {
    final manager = $$CourseItemDetailRowsTableTableManager(
      $_db,
      $_db.courseItemDetailRows,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseItemDetailRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AgendaItemRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AgendaItemRowsTable> {
  $$AgendaItemRowsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
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

  Expression<bool> scheduleItemDetailRowsRefs(
    Expression<bool> Function($$ScheduleItemDetailRowsTableFilterComposer f) f,
  ) {
    final $$ScheduleItemDetailRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduleItemDetailRows,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleItemDetailRowsTableFilterComposer(
                $db: $db,
                $table: $db.scheduleItemDetailRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> taskItemDetailRowsRefs(
    Expression<bool> Function($$TaskItemDetailRowsTableFilterComposer f) f,
  ) {
    final $$TaskItemDetailRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskItemDetailRows,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskItemDetailRowsTableFilterComposer(
            $db: $db,
            $table: $db.taskItemDetailRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseItemDetailRowsRefs(
    Expression<bool> Function($$CourseItemDetailRowsTableFilterComposer f) f,
  ) {
    final $$CourseItemDetailRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseItemDetailRows,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseItemDetailRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseItemDetailRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AgendaItemRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgendaItemRowsTable> {
  $$AgendaItemRowsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
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
}

class $$AgendaItemRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgendaItemRowsTable> {
  $$AgendaItemRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get reminder =>
      $composableBuilder(column: $table.reminder, builder: (column) => column);

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> scheduleItemDetailRowsRefs<T extends Object>(
    Expression<T> Function($$ScheduleItemDetailRowsTableAnnotationComposer a) f,
  ) {
    final $$ScheduleItemDetailRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduleItemDetailRows,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleItemDetailRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduleItemDetailRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> taskItemDetailRowsRefs<T extends Object>(
    Expression<T> Function($$TaskItemDetailRowsTableAnnotationComposer a) f,
  ) {
    final $$TaskItemDetailRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.taskItemDetailRows,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TaskItemDetailRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.taskItemDetailRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseItemDetailRowsRefs<T extends Object>(
    Expression<T> Function($$CourseItemDetailRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseItemDetailRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseItemDetailRows,
          getReferencedColumn: (t) => t.itemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseItemDetailRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseItemDetailRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AgendaItemRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AgendaItemRowsTable,
          AgendaItemRow,
          $$AgendaItemRowsTableFilterComposer,
          $$AgendaItemRowsTableOrderingComposer,
          $$AgendaItemRowsTableAnnotationComposer,
          $$AgendaItemRowsTableCreateCompanionBuilder,
          $$AgendaItemRowsTableUpdateCompanionBuilder,
          (AgendaItemRow, $$AgendaItemRowsTableReferences),
          AgendaItemRow,
          PrefetchHooks Function({
            bool scheduleItemDetailRowsRefs,
            bool taskItemDetailRowsRefs,
            bool courseItemDetailRowsRefs,
          })
        > {
  $$AgendaItemRowsTableTableManager(
    _$AppDatabase db,
    $AgendaItemRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgendaItemRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgendaItemRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgendaItemRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> reminder = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String> sourceRef = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgendaItemRowsCompanion(
                id: id,
                type: type,
                title: title,
                notes: notes,
                location: location,
                color: color,
                reminder: reminder,
                repeatRule: repeatRule,
                isCompleted: isCompleted,
                completedAt: completedAt,
                sortOrder: sortOrder,
                sourceKind: sourceKind,
                sourceRef: sourceRef,
                remoteId: remoteId,
                revision: revision,
                dirty: dirty,
                deletedAt: deletedAt,
                lastSyncedAt: lastSyncedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String title,
                Value<String> notes = const Value.absent(),
                Value<String> location = const Value.absent(),
                required String color,
                required String reminder,
                required String repeatRule,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String> sourceRef = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AgendaItemRowsCompanion.insert(
                id: id,
                type: type,
                title: title,
                notes: notes,
                location: location,
                color: color,
                reminder: reminder,
                repeatRule: repeatRule,
                isCompleted: isCompleted,
                completedAt: completedAt,
                sortOrder: sortOrder,
                sourceKind: sourceKind,
                sourceRef: sourceRef,
                remoteId: remoteId,
                revision: revision,
                dirty: dirty,
                deletedAt: deletedAt,
                lastSyncedAt: lastSyncedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AgendaItemRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                scheduleItemDetailRowsRefs = false,
                taskItemDetailRowsRefs = false,
                courseItemDetailRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scheduleItemDetailRowsRefs) db.scheduleItemDetailRows,
                    if (taskItemDetailRowsRefs) db.taskItemDetailRows,
                    if (courseItemDetailRowsRefs) db.courseItemDetailRows,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scheduleItemDetailRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$AgendaItemRowsTableReferences
                              ._scheduleItemDetailRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AgendaItemRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleItemDetailRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskItemDetailRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$AgendaItemRowsTableReferences
                              ._taskItemDetailRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AgendaItemRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).taskItemDetailRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseItemDetailRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$AgendaItemRowsTableReferences
                              ._courseItemDetailRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AgendaItemRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseItemDetailRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AgendaItemRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AgendaItemRowsTable,
      AgendaItemRow,
      $$AgendaItemRowsTableFilterComposer,
      $$AgendaItemRowsTableOrderingComposer,
      $$AgendaItemRowsTableAnnotationComposer,
      $$AgendaItemRowsTableCreateCompanionBuilder,
      $$AgendaItemRowsTableUpdateCompanionBuilder,
      (AgendaItemRow, $$AgendaItemRowsTableReferences),
      AgendaItemRow,
      PrefetchHooks Function({
        bool scheduleItemDetailRowsRefs,
        bool taskItemDetailRowsRefs,
        bool courseItemDetailRowsRefs,
      })
    >;
typedef $$ScheduleItemDetailRowsTableCreateCompanionBuilder =
    ScheduleItemDetailRowsCompanion Function({
      required String itemId,
      required DateTime startAt,
      required DateTime endAt,
      Value<bool> isAllDay,
      Value<bool> countdownEnabled,
      Value<DateTime?> autoCompletedOnceAt,
      Value<int> rowid,
    });
typedef $$ScheduleItemDetailRowsTableUpdateCompanionBuilder =
    ScheduleItemDetailRowsCompanion Function({
      Value<String> itemId,
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<bool> isAllDay,
      Value<bool> countdownEnabled,
      Value<DateTime?> autoCompletedOnceAt,
      Value<int> rowid,
    });

final class $$ScheduleItemDetailRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScheduleItemDetailRowsTable,
          ScheduleItemDetailRow
        > {
  $$ScheduleItemDetailRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AgendaItemRowsTable _itemIdTable(_$AppDatabase db) =>
      db.agendaItemRows.createAlias(
        $_aliasNameGenerator(
          db.scheduleItemDetailRows.itemId,
          db.agendaItemRows.id,
        ),
      );

  $$AgendaItemRowsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$AgendaItemRowsTableTableManager(
      $_db,
      $_db.agendaItemRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduleItemDetailRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleItemDetailRowsTable> {
  $$ScheduleItemDetailRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get countdownEnabled => $composableBuilder(
    column: $table.countdownEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get autoCompletedOnceAt => $composableBuilder(
    column: $table.autoCompletedOnceAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AgendaItemRowsTableFilterComposer get itemId {
    final $$AgendaItemRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.agendaItemRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgendaItemRowsTableFilterComposer(
            $db: $db,
            $table: $db.agendaItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleItemDetailRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleItemDetailRowsTable> {
  $$ScheduleItemDetailRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get countdownEnabled => $composableBuilder(
    column: $table.countdownEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get autoCompletedOnceAt => $composableBuilder(
    column: $table.autoCompletedOnceAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AgendaItemRowsTableOrderingComposer get itemId {
    final $$AgendaItemRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.agendaItemRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgendaItemRowsTableOrderingComposer(
            $db: $db,
            $table: $db.agendaItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleItemDetailRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleItemDetailRowsTable> {
  $$ScheduleItemDetailRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<bool> get countdownEnabled => $composableBuilder(
    column: $table.countdownEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get autoCompletedOnceAt => $composableBuilder(
    column: $table.autoCompletedOnceAt,
    builder: (column) => column,
  );

  $$AgendaItemRowsTableAnnotationComposer get itemId {
    final $$AgendaItemRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.agendaItemRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgendaItemRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.agendaItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleItemDetailRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleItemDetailRowsTable,
          ScheduleItemDetailRow,
          $$ScheduleItemDetailRowsTableFilterComposer,
          $$ScheduleItemDetailRowsTableOrderingComposer,
          $$ScheduleItemDetailRowsTableAnnotationComposer,
          $$ScheduleItemDetailRowsTableCreateCompanionBuilder,
          $$ScheduleItemDetailRowsTableUpdateCompanionBuilder,
          (ScheduleItemDetailRow, $$ScheduleItemDetailRowsTableReferences),
          ScheduleItemDetailRow,
          PrefetchHooks Function({bool itemId})
        > {
  $$ScheduleItemDetailRowsTableTableManager(
    _$AppDatabase db,
    $ScheduleItemDetailRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleItemDetailRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScheduleItemDetailRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScheduleItemDetailRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<bool> countdownEnabled = const Value.absent(),
                Value<DateTime?> autoCompletedOnceAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleItemDetailRowsCompanion(
                itemId: itemId,
                startAt: startAt,
                endAt: endAt,
                isAllDay: isAllDay,
                countdownEnabled: countdownEnabled,
                autoCompletedOnceAt: autoCompletedOnceAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required DateTime startAt,
                required DateTime endAt,
                Value<bool> isAllDay = const Value.absent(),
                Value<bool> countdownEnabled = const Value.absent(),
                Value<DateTime?> autoCompletedOnceAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleItemDetailRowsCompanion.insert(
                itemId: itemId,
                startAt: startAt,
                endAt: endAt,
                isAllDay: isAllDay,
                countdownEnabled: countdownEnabled,
                autoCompletedOnceAt: autoCompletedOnceAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScheduleItemDetailRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable:
                                    $$ScheduleItemDetailRowsTableReferences
                                        ._itemIdTable(db),
                                referencedColumn:
                                    $$ScheduleItemDetailRowsTableReferences
                                        ._itemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScheduleItemDetailRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleItemDetailRowsTable,
      ScheduleItemDetailRow,
      $$ScheduleItemDetailRowsTableFilterComposer,
      $$ScheduleItemDetailRowsTableOrderingComposer,
      $$ScheduleItemDetailRowsTableAnnotationComposer,
      $$ScheduleItemDetailRowsTableCreateCompanionBuilder,
      $$ScheduleItemDetailRowsTableUpdateCompanionBuilder,
      (ScheduleItemDetailRow, $$ScheduleItemDetailRowsTableReferences),
      ScheduleItemDetailRow,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$TaskItemDetailRowsTableCreateCompanionBuilder =
    TaskItemDetailRowsCompanion Function({
      required String itemId,
      required DateTime deadlineAt,
      Value<int> rowid,
    });
typedef $$TaskItemDetailRowsTableUpdateCompanionBuilder =
    TaskItemDetailRowsCompanion Function({
      Value<String> itemId,
      Value<DateTime> deadlineAt,
      Value<int> rowid,
    });

final class $$TaskItemDetailRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TaskItemDetailRowsTable,
          TaskItemDetailRow
        > {
  $$TaskItemDetailRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AgendaItemRowsTable _itemIdTable(_$AppDatabase db) =>
      db.agendaItemRows.createAlias(
        $_aliasNameGenerator(
          db.taskItemDetailRows.itemId,
          db.agendaItemRows.id,
        ),
      );

  $$AgendaItemRowsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$AgendaItemRowsTableTableManager(
      $_db,
      $_db.agendaItemRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskItemDetailRowsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskItemDetailRowsTable> {
  $$TaskItemDetailRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AgendaItemRowsTableFilterComposer get itemId {
    final $$AgendaItemRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.agendaItemRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgendaItemRowsTableFilterComposer(
            $db: $db,
            $table: $db.agendaItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskItemDetailRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskItemDetailRowsTable> {
  $$TaskItemDetailRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AgendaItemRowsTableOrderingComposer get itemId {
    final $$AgendaItemRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.agendaItemRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgendaItemRowsTableOrderingComposer(
            $db: $db,
            $table: $db.agendaItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskItemDetailRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskItemDetailRowsTable> {
  $$TaskItemDetailRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => column,
  );

  $$AgendaItemRowsTableAnnotationComposer get itemId {
    final $$AgendaItemRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.agendaItemRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgendaItemRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.agendaItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskItemDetailRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskItemDetailRowsTable,
          TaskItemDetailRow,
          $$TaskItemDetailRowsTableFilterComposer,
          $$TaskItemDetailRowsTableOrderingComposer,
          $$TaskItemDetailRowsTableAnnotationComposer,
          $$TaskItemDetailRowsTableCreateCompanionBuilder,
          $$TaskItemDetailRowsTableUpdateCompanionBuilder,
          (TaskItemDetailRow, $$TaskItemDetailRowsTableReferences),
          TaskItemDetailRow,
          PrefetchHooks Function({bool itemId})
        > {
  $$TaskItemDetailRowsTableTableManager(
    _$AppDatabase db,
    $TaskItemDetailRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskItemDetailRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskItemDetailRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskItemDetailRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<DateTime> deadlineAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskItemDetailRowsCompanion(
                itemId: itemId,
                deadlineAt: deadlineAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required DateTime deadlineAt,
                Value<int> rowid = const Value.absent(),
              }) => TaskItemDetailRowsCompanion.insert(
                itemId: itemId,
                deadlineAt: deadlineAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskItemDetailRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable:
                                    $$TaskItemDetailRowsTableReferences
                                        ._itemIdTable(db),
                                referencedColumn:
                                    $$TaskItemDetailRowsTableReferences
                                        ._itemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskItemDetailRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskItemDetailRowsTable,
      TaskItemDetailRow,
      $$TaskItemDetailRowsTableFilterComposer,
      $$TaskItemDetailRowsTableOrderingComposer,
      $$TaskItemDetailRowsTableAnnotationComposer,
      $$TaskItemDetailRowsTableCreateCompanionBuilder,
      $$TaskItemDetailRowsTableUpdateCompanionBuilder,
      (TaskItemDetailRow, $$TaskItemDetailRowsTableReferences),
      TaskItemDetailRow,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$CourseItemDetailRowsTableCreateCompanionBuilder =
    CourseItemDetailRowsCompanion Function({
      required String itemId,
      required DateTime startAt,
      required DateTime endAt,
      Value<bool> isAllDay,
      Value<String> timetableId,
      Value<String> sourceKind,
      Value<String> sourceCourseId,
      Value<String> courseNature,
      Value<String> instructor,
      Value<String> weekMeta,
      Value<String> termCourseId,
      Value<String> offeringId,
      Value<String> instructorCourseId,
      Value<String> occurrenceId,
      Value<int> rowid,
    });
typedef $$CourseItemDetailRowsTableUpdateCompanionBuilder =
    CourseItemDetailRowsCompanion Function({
      Value<String> itemId,
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<bool> isAllDay,
      Value<String> timetableId,
      Value<String> sourceKind,
      Value<String> sourceCourseId,
      Value<String> courseNature,
      Value<String> instructor,
      Value<String> weekMeta,
      Value<String> termCourseId,
      Value<String> offeringId,
      Value<String> instructorCourseId,
      Value<String> occurrenceId,
      Value<int> rowid,
    });

final class $$CourseItemDetailRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CourseItemDetailRowsTable,
          CourseItemDetailRow
        > {
  $$CourseItemDetailRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AgendaItemRowsTable _itemIdTable(_$AppDatabase db) =>
      db.agendaItemRows.createAlias(
        $_aliasNameGenerator(
          db.courseItemDetailRows.itemId,
          db.agendaItemRows.id,
        ),
      );

  $$AgendaItemRowsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$AgendaItemRowsTableTableManager(
      $_db,
      $_db.agendaItemRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CourseItemDetailRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseItemDetailRowsTable> {
  $$CourseItemDetailRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timetableId => $composableBuilder(
    column: $table.timetableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceCourseId => $composableBuilder(
    column: $table.sourceCourseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructor => $composableBuilder(
    column: $table.instructor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekMeta => $composableBuilder(
    column: $table.weekMeta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get termCourseId => $composableBuilder(
    column: $table.termCourseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get offeringId => $composableBuilder(
    column: $table.offeringId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructorCourseId => $composableBuilder(
    column: $table.instructorCourseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnFilters(column),
  );

  $$AgendaItemRowsTableFilterComposer get itemId {
    final $$AgendaItemRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.agendaItemRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgendaItemRowsTableFilterComposer(
            $db: $db,
            $table: $db.agendaItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseItemDetailRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseItemDetailRowsTable> {
  $$CourseItemDetailRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timetableId => $composableBuilder(
    column: $table.timetableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceCourseId => $composableBuilder(
    column: $table.sourceCourseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructor => $composableBuilder(
    column: $table.instructor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekMeta => $composableBuilder(
    column: $table.weekMeta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get termCourseId => $composableBuilder(
    column: $table.termCourseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get offeringId => $composableBuilder(
    column: $table.offeringId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructorCourseId => $composableBuilder(
    column: $table.instructorCourseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnOrderings(column),
  );

  $$AgendaItemRowsTableOrderingComposer get itemId {
    final $$AgendaItemRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.agendaItemRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgendaItemRowsTableOrderingComposer(
            $db: $db,
            $table: $db.agendaItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseItemDetailRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseItemDetailRowsTable> {
  $$CourseItemDetailRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<String> get timetableId => $composableBuilder(
    column: $table.timetableId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceCourseId => $composableBuilder(
    column: $table.sourceCourseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructor => $composableBuilder(
    column: $table.instructor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekMeta =>
      $composableBuilder(column: $table.weekMeta, builder: (column) => column);

  GeneratedColumn<String> get termCourseId => $composableBuilder(
    column: $table.termCourseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get offeringId => $composableBuilder(
    column: $table.offeringId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructorCourseId => $composableBuilder(
    column: $table.instructorCourseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => column,
  );

  $$AgendaItemRowsTableAnnotationComposer get itemId {
    final $$AgendaItemRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.agendaItemRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgendaItemRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.agendaItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseItemDetailRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseItemDetailRowsTable,
          CourseItemDetailRow,
          $$CourseItemDetailRowsTableFilterComposer,
          $$CourseItemDetailRowsTableOrderingComposer,
          $$CourseItemDetailRowsTableAnnotationComposer,
          $$CourseItemDetailRowsTableCreateCompanionBuilder,
          $$CourseItemDetailRowsTableUpdateCompanionBuilder,
          (CourseItemDetailRow, $$CourseItemDetailRowsTableReferences),
          CourseItemDetailRow,
          PrefetchHooks Function({bool itemId})
        > {
  $$CourseItemDetailRowsTableTableManager(
    _$AppDatabase db,
    $CourseItemDetailRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseItemDetailRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseItemDetailRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CourseItemDetailRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<String> timetableId = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String> sourceCourseId = const Value.absent(),
                Value<String> courseNature = const Value.absent(),
                Value<String> instructor = const Value.absent(),
                Value<String> weekMeta = const Value.absent(),
                Value<String> termCourseId = const Value.absent(),
                Value<String> offeringId = const Value.absent(),
                Value<String> instructorCourseId = const Value.absent(),
                Value<String> occurrenceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseItemDetailRowsCompanion(
                itemId: itemId,
                startAt: startAt,
                endAt: endAt,
                isAllDay: isAllDay,
                timetableId: timetableId,
                sourceKind: sourceKind,
                sourceCourseId: sourceCourseId,
                courseNature: courseNature,
                instructor: instructor,
                weekMeta: weekMeta,
                termCourseId: termCourseId,
                offeringId: offeringId,
                instructorCourseId: instructorCourseId,
                occurrenceId: occurrenceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required DateTime startAt,
                required DateTime endAt,
                Value<bool> isAllDay = const Value.absent(),
                Value<String> timetableId = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String> sourceCourseId = const Value.absent(),
                Value<String> courseNature = const Value.absent(),
                Value<String> instructor = const Value.absent(),
                Value<String> weekMeta = const Value.absent(),
                Value<String> termCourseId = const Value.absent(),
                Value<String> offeringId = const Value.absent(),
                Value<String> instructorCourseId = const Value.absent(),
                Value<String> occurrenceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseItemDetailRowsCompanion.insert(
                itemId: itemId,
                startAt: startAt,
                endAt: endAt,
                isAllDay: isAllDay,
                timetableId: timetableId,
                sourceKind: sourceKind,
                sourceCourseId: sourceCourseId,
                courseNature: courseNature,
                instructor: instructor,
                weekMeta: weekMeta,
                termCourseId: termCourseId,
                offeringId: offeringId,
                instructorCourseId: instructorCourseId,
                occurrenceId: occurrenceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseItemDetailRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable:
                                    $$CourseItemDetailRowsTableReferences
                                        ._itemIdTable(db),
                                referencedColumn:
                                    $$CourseItemDetailRowsTableReferences
                                        ._itemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CourseItemDetailRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseItemDetailRowsTable,
      CourseItemDetailRow,
      $$CourseItemDetailRowsTableFilterComposer,
      $$CourseItemDetailRowsTableOrderingComposer,
      $$CourseItemDetailRowsTableAnnotationComposer,
      $$CourseItemDetailRowsTableCreateCompanionBuilder,
      $$CourseItemDetailRowsTableUpdateCompanionBuilder,
      (CourseItemDetailRow, $$CourseItemDetailRowsTableReferences),
      CourseItemDetailRow,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$CourseTimetableRowsTableCreateCompanionBuilder =
    CourseTimetableRowsCompanion Function({
      required String id,
      required String name,
      required String source,
      Value<String> termLabel,
      Value<String?> remoteId,
      Value<int> revision,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<DateTime?> lastSyncedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CourseTimetableRowsTableUpdateCompanionBuilder =
    CourseTimetableRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> source,
      Value<String> termLabel,
      Value<String?> remoteId,
      Value<int> revision,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CourseTimetableRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CourseTimetableRowsTable,
          CourseTimetableRow
        > {
  $$CourseTimetableRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $SelectedCourseTimetableRowsTable,
    List<SelectedCourseTimetableRow>
  >
  _selectedCourseTimetableRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.selectedCourseTimetableRows,
        aliasName: $_aliasNameGenerator(
          db.courseTimetableRows.id,
          db.selectedCourseTimetableRows.timetableId,
        ),
      );

  $$SelectedCourseTimetableRowsTableProcessedTableManager
  get selectedCourseTimetableRowsRefs {
    final manager = $$SelectedCourseTimetableRowsTableTableManager(
      $_db,
      $_db.selectedCourseTimetableRows,
    ).filter((f) => f.timetableId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _selectedCourseTimetableRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CourseTimetableRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseTimetableRowsTable> {
  $$CourseTimetableRowsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get termLabel => $composableBuilder(
    column: $table.termLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
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

  Expression<bool> selectedCourseTimetableRowsRefs(
    Expression<bool> Function(
      $$SelectedCourseTimetableRowsTableFilterComposer f,
    )
    f,
  ) {
    final $$SelectedCourseTimetableRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.selectedCourseTimetableRows,
          getReferencedColumn: (t) => t.timetableId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SelectedCourseTimetableRowsTableFilterComposer(
                $db: $db,
                $table: $db.selectedCourseTimetableRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CourseTimetableRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseTimetableRowsTable> {
  $$CourseTimetableRowsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get termLabel => $composableBuilder(
    column: $table.termLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
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
}

class $$CourseTimetableRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseTimetableRowsTable> {
  $$CourseTimetableRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get termLabel =>
      $composableBuilder(column: $table.termLabel, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> selectedCourseTimetableRowsRefs<T extends Object>(
    Expression<T> Function(
      $$SelectedCourseTimetableRowsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SelectedCourseTimetableRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.selectedCourseTimetableRows,
          getReferencedColumn: (t) => t.timetableId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SelectedCourseTimetableRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.selectedCourseTimetableRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CourseTimetableRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseTimetableRowsTable,
          CourseTimetableRow,
          $$CourseTimetableRowsTableFilterComposer,
          $$CourseTimetableRowsTableOrderingComposer,
          $$CourseTimetableRowsTableAnnotationComposer,
          $$CourseTimetableRowsTableCreateCompanionBuilder,
          $$CourseTimetableRowsTableUpdateCompanionBuilder,
          (CourseTimetableRow, $$CourseTimetableRowsTableReferences),
          CourseTimetableRow,
          PrefetchHooks Function({bool selectedCourseTimetableRowsRefs})
        > {
  $$CourseTimetableRowsTableTableManager(
    _$AppDatabase db,
    $CourseTimetableRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseTimetableRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseTimetableRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CourseTimetableRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> termLabel = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseTimetableRowsCompanion(
                id: id,
                name: name,
                source: source,
                termLabel: termLabel,
                remoteId: remoteId,
                revision: revision,
                dirty: dirty,
                deletedAt: deletedAt,
                lastSyncedAt: lastSyncedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String source,
                Value<String> termLabel = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CourseTimetableRowsCompanion.insert(
                id: id,
                name: name,
                source: source,
                termLabel: termLabel,
                remoteId: remoteId,
                revision: revision,
                dirty: dirty,
                deletedAt: deletedAt,
                lastSyncedAt: lastSyncedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseTimetableRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({selectedCourseTimetableRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (selectedCourseTimetableRowsRefs)
                  db.selectedCourseTimetableRows,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (selectedCourseTimetableRowsRefs)
                    await $_getPrefetchedData(
                      currentTable: table,
                      referencedTable: $$CourseTimetableRowsTableReferences
                          ._selectedCourseTimetableRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CourseTimetableRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).selectedCourseTimetableRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.timetableId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CourseTimetableRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseTimetableRowsTable,
      CourseTimetableRow,
      $$CourseTimetableRowsTableFilterComposer,
      $$CourseTimetableRowsTableOrderingComposer,
      $$CourseTimetableRowsTableAnnotationComposer,
      $$CourseTimetableRowsTableCreateCompanionBuilder,
      $$CourseTimetableRowsTableUpdateCompanionBuilder,
      (CourseTimetableRow, $$CourseTimetableRowsTableReferences),
      CourseTimetableRow,
      PrefetchHooks Function({bool selectedCourseTimetableRowsRefs})
    >;
typedef $$SelectedCourseTimetableRowsTableCreateCompanionBuilder =
    SelectedCourseTimetableRowsCompanion Function({
      required String timetableId,
      Value<double> sortOrder,
      Value<int> revision,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<DateTime?> lastSyncedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SelectedCourseTimetableRowsTableUpdateCompanionBuilder =
    SelectedCourseTimetableRowsCompanion Function({
      Value<String> timetableId,
      Value<double> sortOrder,
      Value<int> revision,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SelectedCourseTimetableRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SelectedCourseTimetableRowsTable,
          SelectedCourseTimetableRow
        > {
  $$SelectedCourseTimetableRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CourseTimetableRowsTable _timetableIdTable(_$AppDatabase db) =>
      db.courseTimetableRows.createAlias(
        $_aliasNameGenerator(
          db.selectedCourseTimetableRows.timetableId,
          db.courseTimetableRows.id,
        ),
      );

  $$CourseTimetableRowsTableProcessedTableManager get timetableId {
    final $_column = $_itemColumn<String>('timetable_id')!;

    final manager = $$CourseTimetableRowsTableTableManager(
      $_db,
      $_db.courseTimetableRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_timetableIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SelectedCourseTimetableRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SelectedCourseTimetableRowsTable> {
  $$SelectedCourseTimetableRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CourseTimetableRowsTableFilterComposer get timetableId {
    final $$CourseTimetableRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timetableId,
      referencedTable: $db.courseTimetableRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTimetableRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseTimetableRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelectedCourseTimetableRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SelectedCourseTimetableRowsTable> {
  $$SelectedCourseTimetableRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CourseTimetableRowsTableOrderingComposer get timetableId {
    final $$CourseTimetableRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.timetableId,
          referencedTable: $db.courseTimetableRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTimetableRowsTableOrderingComposer(
                $db: $db,
                $table: $db.courseTimetableRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SelectedCourseTimetableRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SelectedCourseTimetableRowsTable> {
  $$SelectedCourseTimetableRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CourseTimetableRowsTableAnnotationComposer get timetableId {
    final $$CourseTimetableRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.timetableId,
          referencedTable: $db.courseTimetableRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTimetableRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseTimetableRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SelectedCourseTimetableRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SelectedCourseTimetableRowsTable,
          SelectedCourseTimetableRow,
          $$SelectedCourseTimetableRowsTableFilterComposer,
          $$SelectedCourseTimetableRowsTableOrderingComposer,
          $$SelectedCourseTimetableRowsTableAnnotationComposer,
          $$SelectedCourseTimetableRowsTableCreateCompanionBuilder,
          $$SelectedCourseTimetableRowsTableUpdateCompanionBuilder,
          (
            SelectedCourseTimetableRow,
            $$SelectedCourseTimetableRowsTableReferences,
          ),
          SelectedCourseTimetableRow,
          PrefetchHooks Function({bool timetableId})
        > {
  $$SelectedCourseTimetableRowsTableTableManager(
    _$AppDatabase db,
    $SelectedCourseTimetableRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SelectedCourseTimetableRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SelectedCourseTimetableRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SelectedCourseTimetableRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> timetableId = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SelectedCourseTimetableRowsCompanion(
                timetableId: timetableId,
                sortOrder: sortOrder,
                revision: revision,
                dirty: dirty,
                deletedAt: deletedAt,
                lastSyncedAt: lastSyncedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String timetableId,
                Value<double> sortOrder = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SelectedCourseTimetableRowsCompanion.insert(
                timetableId: timetableId,
                sortOrder: sortOrder,
                revision: revision,
                dirty: dirty,
                deletedAt: deletedAt,
                lastSyncedAt: lastSyncedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SelectedCourseTimetableRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({timetableId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (timetableId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.timetableId,
                                referencedTable:
                                    $$SelectedCourseTimetableRowsTableReferences
                                        ._timetableIdTable(db),
                                referencedColumn:
                                    $$SelectedCourseTimetableRowsTableReferences
                                        ._timetableIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SelectedCourseTimetableRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SelectedCourseTimetableRowsTable,
      SelectedCourseTimetableRow,
      $$SelectedCourseTimetableRowsTableFilterComposer,
      $$SelectedCourseTimetableRowsTableOrderingComposer,
      $$SelectedCourseTimetableRowsTableAnnotationComposer,
      $$SelectedCourseTimetableRowsTableCreateCompanionBuilder,
      $$SelectedCourseTimetableRowsTableUpdateCompanionBuilder,
      (
        SelectedCourseTimetableRow,
        $$SelectedCourseTimetableRowsTableReferences,
      ),
      SelectedCourseTimetableRow,
      PrefetchHooks Function({bool timetableId})
    >;
typedef $$SchoolTimetableTermRowsTableCreateCompanionBuilder =
    SchoolTimetableTermRowsCompanion Function({
      required String termKey,
      required String schoolYear,
      required String term,
      required String firstWeekMonday,
      Value<String> sourceVersion,
      Value<int> rowCount,
      required DateTime importedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SchoolTimetableTermRowsTableUpdateCompanionBuilder =
    SchoolTimetableTermRowsCompanion Function({
      Value<String> termKey,
      Value<String> schoolYear,
      Value<String> term,
      Value<String> firstWeekMonday,
      Value<String> sourceVersion,
      Value<int> rowCount,
      Value<DateTime> importedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SchoolTimetableTermRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SchoolTimetableTermRowsTable,
          SchoolTimetableTermRow
        > {
  $$SchoolTimetableTermRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CourseTermCourseRowsTable,
    List<CourseTermCourseRow>
  >
  _courseTermCourseRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseTermCourseRows,
        aliasName: $_aliasNameGenerator(
          db.schoolTimetableTermRows.termKey,
          db.courseTermCourseRows.termKey,
        ),
      );

  $$CourseTermCourseRowsTableProcessedTableManager
  get courseTermCourseRowsRefs {
    final manager =
        $$CourseTermCourseRowsTableTableManager(
          $_db,
          $_db.courseTermCourseRows,
        ).filter(
          (f) => f.termKey.termKey.sqlEquals($_itemColumn<String>('term_key')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _courseTermCourseRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CourseOfferingRowsTable, List<CourseOfferingRow>>
  _courseOfferingRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseOfferingRows,
        aliasName: $_aliasNameGenerator(
          db.schoolTimetableTermRows.termKey,
          db.courseOfferingRows.termKey,
        ),
      );

  $$CourseOfferingRowsTableProcessedTableManager get courseOfferingRowsRefs {
    final manager =
        $$CourseOfferingRowsTableTableManager(
          $_db,
          $_db.courseOfferingRows,
        ).filter(
          (f) => f.termKey.termKey.sqlEquals($_itemColumn<String>('term_key')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _courseOfferingRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CourseAudienceRowsTable, List<CourseAudienceRow>>
  _courseAudienceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseAudienceRows,
        aliasName: $_aliasNameGenerator(
          db.schoolTimetableTermRows.termKey,
          db.courseAudienceRows.termKey,
        ),
      );

  $$CourseAudienceRowsTableProcessedTableManager get courseAudienceRowsRefs {
    final manager =
        $$CourseAudienceRowsTableTableManager(
          $_db,
          $_db.courseAudienceRows,
        ).filter(
          (f) => f.termKey.termKey.sqlEquals($_itemColumn<String>('term_key')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _courseAudienceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CourseSourceRowsTable, List<CourseSourceRow>>
  _courseSourceRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.courseSourceRows,
    aliasName: $_aliasNameGenerator(
      db.schoolTimetableTermRows.termKey,
      db.courseSourceRows.termKey,
    ),
  );

  $$CourseSourceRowsTableProcessedTableManager get courseSourceRowsRefs {
    final manager =
        $$CourseSourceRowsTableTableManager($_db, $_db.courseSourceRows).filter(
          (f) => f.termKey.termKey.sqlEquals($_itemColumn<String>('term_key')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _courseSourceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CourseMeetingRuleRowsTable,
    List<CourseMeetingRuleRow>
  >
  _courseMeetingRuleRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseMeetingRuleRows,
        aliasName: $_aliasNameGenerator(
          db.schoolTimetableTermRows.termKey,
          db.courseMeetingRuleRows.termKey,
        ),
      );

  $$CourseMeetingRuleRowsTableProcessedTableManager
  get courseMeetingRuleRowsRefs {
    final manager =
        $$CourseMeetingRuleRowsTableTableManager(
          $_db,
          $_db.courseMeetingRuleRows,
        ).filter(
          (f) => f.termKey.termKey.sqlEquals($_itemColumn<String>('term_key')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _courseMeetingRuleRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CourseOccurrenceRowsTable,
    List<CourseOccurrenceRow>
  >
  _courseOccurrenceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseOccurrenceRows,
        aliasName: $_aliasNameGenerator(
          db.schoolTimetableTermRows.termKey,
          db.courseOccurrenceRows.termKey,
        ),
      );

  $$CourseOccurrenceRowsTableProcessedTableManager
  get courseOccurrenceRowsRefs {
    final manager =
        $$CourseOccurrenceRowsTableTableManager(
          $_db,
          $_db.courseOccurrenceRows,
        ).filter(
          (f) => f.termKey.termKey.sqlEquals($_itemColumn<String>('term_key')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _courseOccurrenceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SchoolTimetableTermRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolTimetableTermRowsTable> {
  $$SchoolTimetableTermRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get termKey => $composableBuilder(
    column: $table.termKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstWeekMonday => $composableBuilder(
    column: $table.firstWeekMonday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> courseTermCourseRowsRefs(
    Expression<bool> Function($$CourseTermCourseRowsTableFilterComposer f) f,
  ) {
    final $$CourseTermCourseRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termKey,
      referencedTable: $db.courseTermCourseRows,
      getReferencedColumn: (t) => t.termKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTermCourseRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseTermCourseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseOfferingRowsRefs(
    Expression<bool> Function($$CourseOfferingRowsTableFilterComposer f) f,
  ) {
    final $$CourseOfferingRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termKey,
      referencedTable: $db.courseOfferingRows,
      getReferencedColumn: (t) => t.termKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOfferingRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOfferingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseAudienceRowsRefs(
    Expression<bool> Function($$CourseAudienceRowsTableFilterComposer f) f,
  ) {
    final $$CourseAudienceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termKey,
      referencedTable: $db.courseAudienceRows,
      getReferencedColumn: (t) => t.termKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseAudienceRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseAudienceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseSourceRowsRefs(
    Expression<bool> Function($$CourseSourceRowsTableFilterComposer f) f,
  ) {
    final $$CourseSourceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termKey,
      referencedTable: $db.courseSourceRows,
      getReferencedColumn: (t) => t.termKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseSourceRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseSourceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseMeetingRuleRowsRefs(
    Expression<bool> Function($$CourseMeetingRuleRowsTableFilterComposer f) f,
  ) {
    final $$CourseMeetingRuleRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableFilterComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> courseOccurrenceRowsRefs(
    Expression<bool> Function($$CourseOccurrenceRowsTableFilterComposer f) f,
  ) {
    final $$CourseOccurrenceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termKey,
      referencedTable: $db.courseOccurrenceRows,
      getReferencedColumn: (t) => t.termKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOccurrenceRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOccurrenceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SchoolTimetableTermRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolTimetableTermRowsTable> {
  $$SchoolTimetableTermRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get termKey => $composableBuilder(
    column: $table.termKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstWeekMonday => $composableBuilder(
    column: $table.firstWeekMonday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchoolTimetableTermRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolTimetableTermRowsTable> {
  $$SchoolTimetableTermRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get termKey =>
      $composableBuilder(column: $table.termKey, builder: (column) => column);

  GeneratedColumn<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get firstWeekMonday => $composableBuilder(
    column: $table.firstWeekMonday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rowCount =>
      $composableBuilder(column: $table.rowCount, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> courseTermCourseRowsRefs<T extends Object>(
    Expression<T> Function($$CourseTermCourseRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseTermCourseRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.courseTermCourseRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTermCourseRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseTermCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseOfferingRowsRefs<T extends Object>(
    Expression<T> Function($$CourseOfferingRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseOfferingRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.courseOfferingRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOfferingRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOfferingRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseAudienceRowsRefs<T extends Object>(
    Expression<T> Function($$CourseAudienceRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseAudienceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.courseAudienceRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseAudienceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseAudienceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseSourceRowsRefs<T extends Object>(
    Expression<T> Function($$CourseSourceRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseSourceRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termKey,
      referencedTable: $db.courseSourceRows,
      getReferencedColumn: (t) => t.termKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseSourceRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.courseSourceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> courseMeetingRuleRowsRefs<T extends Object>(
    Expression<T> Function($$CourseMeetingRuleRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseMeetingRuleRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseOccurrenceRowsRefs<T extends Object>(
    Expression<T> Function($$CourseOccurrenceRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseOccurrenceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.courseOccurrenceRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOccurrenceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOccurrenceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SchoolTimetableTermRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchoolTimetableTermRowsTable,
          SchoolTimetableTermRow,
          $$SchoolTimetableTermRowsTableFilterComposer,
          $$SchoolTimetableTermRowsTableOrderingComposer,
          $$SchoolTimetableTermRowsTableAnnotationComposer,
          $$SchoolTimetableTermRowsTableCreateCompanionBuilder,
          $$SchoolTimetableTermRowsTableUpdateCompanionBuilder,
          (SchoolTimetableTermRow, $$SchoolTimetableTermRowsTableReferences),
          SchoolTimetableTermRow,
          PrefetchHooks Function({
            bool courseTermCourseRowsRefs,
            bool courseOfferingRowsRefs,
            bool courseAudienceRowsRefs,
            bool courseSourceRowsRefs,
            bool courseMeetingRuleRowsRefs,
            bool courseOccurrenceRowsRefs,
          })
        > {
  $$SchoolTimetableTermRowsTableTableManager(
    _$AppDatabase db,
    $SchoolTimetableTermRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolTimetableTermRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SchoolTimetableTermRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SchoolTimetableTermRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> termKey = const Value.absent(),
                Value<String> schoolYear = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String> firstWeekMonday = const Value.absent(),
                Value<String> sourceVersion = const Value.absent(),
                Value<int> rowCount = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolTimetableTermRowsCompanion(
                termKey: termKey,
                schoolYear: schoolYear,
                term: term,
                firstWeekMonday: firstWeekMonday,
                sourceVersion: sourceVersion,
                rowCount: rowCount,
                importedAt: importedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String termKey,
                required String schoolYear,
                required String term,
                required String firstWeekMonday,
                Value<String> sourceVersion = const Value.absent(),
                Value<int> rowCount = const Value.absent(),
                required DateTime importedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SchoolTimetableTermRowsCompanion.insert(
                termKey: termKey,
                schoolYear: schoolYear,
                term: term,
                firstWeekMonday: firstWeekMonday,
                sourceVersion: sourceVersion,
                rowCount: rowCount,
                importedAt: importedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SchoolTimetableTermRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                courseTermCourseRowsRefs = false,
                courseOfferingRowsRefs = false,
                courseAudienceRowsRefs = false,
                courseSourceRowsRefs = false,
                courseMeetingRuleRowsRefs = false,
                courseOccurrenceRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (courseTermCourseRowsRefs) db.courseTermCourseRows,
                    if (courseOfferingRowsRefs) db.courseOfferingRows,
                    if (courseAudienceRowsRefs) db.courseAudienceRows,
                    if (courseSourceRowsRefs) db.courseSourceRows,
                    if (courseMeetingRuleRowsRefs) db.courseMeetingRuleRows,
                    if (courseOccurrenceRowsRefs) db.courseOccurrenceRows,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (courseTermCourseRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable:
                              $$SchoolTimetableTermRowsTableReferences
                                  ._courseTermCourseRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolTimetableTermRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseTermCourseRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.termKey == item.termKey,
                              ),
                          typedResults: items,
                        ),
                      if (courseOfferingRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable:
                              $$SchoolTimetableTermRowsTableReferences
                                  ._courseOfferingRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolTimetableTermRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseOfferingRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.termKey == item.termKey,
                              ),
                          typedResults: items,
                        ),
                      if (courseAudienceRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable:
                              $$SchoolTimetableTermRowsTableReferences
                                  ._courseAudienceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolTimetableTermRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseAudienceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.termKey == item.termKey,
                              ),
                          typedResults: items,
                        ),
                      if (courseSourceRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable:
                              $$SchoolTimetableTermRowsTableReferences
                                  ._courseSourceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolTimetableTermRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseSourceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.termKey == item.termKey,
                              ),
                          typedResults: items,
                        ),
                      if (courseMeetingRuleRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable:
                              $$SchoolTimetableTermRowsTableReferences
                                  ._courseMeetingRuleRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolTimetableTermRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseMeetingRuleRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.termKey == item.termKey,
                              ),
                          typedResults: items,
                        ),
                      if (courseOccurrenceRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable:
                              $$SchoolTimetableTermRowsTableReferences
                                  ._courseOccurrenceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchoolTimetableTermRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseOccurrenceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.termKey == item.termKey,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SchoolTimetableTermRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchoolTimetableTermRowsTable,
      SchoolTimetableTermRow,
      $$SchoolTimetableTermRowsTableFilterComposer,
      $$SchoolTimetableTermRowsTableOrderingComposer,
      $$SchoolTimetableTermRowsTableAnnotationComposer,
      $$SchoolTimetableTermRowsTableCreateCompanionBuilder,
      $$SchoolTimetableTermRowsTableUpdateCompanionBuilder,
      (SchoolTimetableTermRow, $$SchoolTimetableTermRowsTableReferences),
      SchoolTimetableTermRow,
      PrefetchHooks Function({
        bool courseTermCourseRowsRefs,
        bool courseOfferingRowsRefs,
        bool courseAudienceRowsRefs,
        bool courseSourceRowsRefs,
        bool courseMeetingRuleRowsRefs,
        bool courseOccurrenceRowsRefs,
      })
    >;
typedef $$CourseCatalogRowsTableCreateCompanionBuilder =
    CourseCatalogRowsCompanion Function({
      required String id,
      required String catalogKey,
      required String courseNo,
      required String courseName,
      Value<double?> credits,
      Value<String> searchText,
      Value<int> rowid,
    });
typedef $$CourseCatalogRowsTableUpdateCompanionBuilder =
    CourseCatalogRowsCompanion Function({
      Value<String> id,
      Value<String> catalogKey,
      Value<String> courseNo,
      Value<String> courseName,
      Value<double?> credits,
      Value<String> searchText,
      Value<int> rowid,
    });

final class $$CourseCatalogRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CourseCatalogRowsTable,
          CourseCatalogRow
        > {
  $$CourseCatalogRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CourseTermCourseRowsTable,
    List<CourseTermCourseRow>
  >
  _courseTermCourseRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseTermCourseRows,
        aliasName: $_aliasNameGenerator(
          db.courseCatalogRows.id,
          db.courseTermCourseRows.catalogId,
        ),
      );

  $$CourseTermCourseRowsTableProcessedTableManager
  get courseTermCourseRowsRefs {
    final manager = $$CourseTermCourseRowsTableTableManager(
      $_db,
      $_db.courseTermCourseRows,
    ).filter((f) => f.catalogId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseTermCourseRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CourseInstructorCourseRowsTable,
    List<CourseInstructorCourseRow>
  >
  _courseInstructorCourseRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseInstructorCourseRows,
        aliasName: $_aliasNameGenerator(
          db.courseCatalogRows.id,
          db.courseInstructorCourseRows.catalogId,
        ),
      );

  $$CourseInstructorCourseRowsTableProcessedTableManager
  get courseInstructorCourseRowsRefs {
    final manager = $$CourseInstructorCourseRowsTableTableManager(
      $_db,
      $_db.courseInstructorCourseRows,
    ).filter((f) => f.catalogId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseInstructorCourseRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CourseOfferingRowsTable, List<CourseOfferingRow>>
  _courseOfferingRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseOfferingRows,
        aliasName: $_aliasNameGenerator(
          db.courseCatalogRows.id,
          db.courseOfferingRows.catalogId,
        ),
      );

  $$CourseOfferingRowsTableProcessedTableManager get courseOfferingRowsRefs {
    final manager = $$CourseOfferingRowsTableTableManager(
      $_db,
      $_db.courseOfferingRows,
    ).filter((f) => f.catalogId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseOfferingRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CourseAudienceRowsTable, List<CourseAudienceRow>>
  _courseAudienceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseAudienceRows,
        aliasName: $_aliasNameGenerator(
          db.courseCatalogRows.id,
          db.courseAudienceRows.catalogId,
        ),
      );

  $$CourseAudienceRowsTableProcessedTableManager get courseAudienceRowsRefs {
    final manager = $$CourseAudienceRowsTableTableManager(
      $_db,
      $_db.courseAudienceRows,
    ).filter((f) => f.catalogId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseAudienceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CourseMeetingRuleRowsTable,
    List<CourseMeetingRuleRow>
  >
  _courseMeetingRuleRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseMeetingRuleRows,
        aliasName: $_aliasNameGenerator(
          db.courseCatalogRows.id,
          db.courseMeetingRuleRows.catalogId,
        ),
      );

  $$CourseMeetingRuleRowsTableProcessedTableManager
  get courseMeetingRuleRowsRefs {
    final manager = $$CourseMeetingRuleRowsTableTableManager(
      $_db,
      $_db.courseMeetingRuleRows,
    ).filter((f) => f.catalogId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseMeetingRuleRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CourseOccurrenceRowsTable,
    List<CourseOccurrenceRow>
  >
  _courseOccurrenceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseOccurrenceRows,
        aliasName: $_aliasNameGenerator(
          db.courseCatalogRows.id,
          db.courseOccurrenceRows.catalogId,
        ),
      );

  $$CourseOccurrenceRowsTableProcessedTableManager
  get courseOccurrenceRowsRefs {
    final manager = $$CourseOccurrenceRowsTableTableManager(
      $_db,
      $_db.courseOccurrenceRows,
    ).filter((f) => f.catalogId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseOccurrenceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CourseCatalogRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseCatalogRowsTable> {
  $$CourseCatalogRowsTableFilterComposer({
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

  ColumnFilters<String> get catalogKey => $composableBuilder(
    column: $table.catalogKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseNo => $composableBuilder(
    column: $table.courseNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> courseTermCourseRowsRefs(
    Expression<bool> Function($$CourseTermCourseRowsTableFilterComposer f) f,
  ) {
    final $$CourseTermCourseRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseTermCourseRows,
      getReferencedColumn: (t) => t.catalogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTermCourseRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseTermCourseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseInstructorCourseRowsRefs(
    Expression<bool> Function($$CourseInstructorCourseRowsTableFilterComposer f)
    f,
  ) {
    final $$CourseInstructorCourseRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseInstructorCourseRows,
          getReferencedColumn: (t) => t.catalogId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseInstructorCourseRowsTableFilterComposer(
                $db: $db,
                $table: $db.courseInstructorCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> courseOfferingRowsRefs(
    Expression<bool> Function($$CourseOfferingRowsTableFilterComposer f) f,
  ) {
    final $$CourseOfferingRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseOfferingRows,
      getReferencedColumn: (t) => t.catalogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOfferingRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOfferingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseAudienceRowsRefs(
    Expression<bool> Function($$CourseAudienceRowsTableFilterComposer f) f,
  ) {
    final $$CourseAudienceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseAudienceRows,
      getReferencedColumn: (t) => t.catalogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseAudienceRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseAudienceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseMeetingRuleRowsRefs(
    Expression<bool> Function($$CourseMeetingRuleRowsTableFilterComposer f) f,
  ) {
    final $$CourseMeetingRuleRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.catalogId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableFilterComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> courseOccurrenceRowsRefs(
    Expression<bool> Function($$CourseOccurrenceRowsTableFilterComposer f) f,
  ) {
    final $$CourseOccurrenceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseOccurrenceRows,
      getReferencedColumn: (t) => t.catalogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOccurrenceRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOccurrenceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseCatalogRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseCatalogRowsTable> {
  $$CourseCatalogRowsTableOrderingComposer({
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

  ColumnOrderings<String> get catalogKey => $composableBuilder(
    column: $table.catalogKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseNo => $composableBuilder(
    column: $table.courseNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CourseCatalogRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseCatalogRowsTable> {
  $$CourseCatalogRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get catalogKey => $composableBuilder(
    column: $table.catalogKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseNo =>
      $composableBuilder(column: $table.courseNo, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  Expression<T> courseTermCourseRowsRefs<T extends Object>(
    Expression<T> Function($$CourseTermCourseRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseTermCourseRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseTermCourseRows,
          getReferencedColumn: (t) => t.catalogId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTermCourseRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseTermCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseInstructorCourseRowsRefs<T extends Object>(
    Expression<T> Function(
      $$CourseInstructorCourseRowsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$CourseInstructorCourseRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseInstructorCourseRows,
          getReferencedColumn: (t) => t.catalogId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseInstructorCourseRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseInstructorCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseOfferingRowsRefs<T extends Object>(
    Expression<T> Function($$CourseOfferingRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseOfferingRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseOfferingRows,
          getReferencedColumn: (t) => t.catalogId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOfferingRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOfferingRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseAudienceRowsRefs<T extends Object>(
    Expression<T> Function($$CourseAudienceRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseAudienceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseAudienceRows,
          getReferencedColumn: (t) => t.catalogId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseAudienceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseAudienceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseMeetingRuleRowsRefs<T extends Object>(
    Expression<T> Function($$CourseMeetingRuleRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseMeetingRuleRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.catalogId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseOccurrenceRowsRefs<T extends Object>(
    Expression<T> Function($$CourseOccurrenceRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseOccurrenceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseOccurrenceRows,
          getReferencedColumn: (t) => t.catalogId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOccurrenceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOccurrenceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CourseCatalogRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseCatalogRowsTable,
          CourseCatalogRow,
          $$CourseCatalogRowsTableFilterComposer,
          $$CourseCatalogRowsTableOrderingComposer,
          $$CourseCatalogRowsTableAnnotationComposer,
          $$CourseCatalogRowsTableCreateCompanionBuilder,
          $$CourseCatalogRowsTableUpdateCompanionBuilder,
          (CourseCatalogRow, $$CourseCatalogRowsTableReferences),
          CourseCatalogRow,
          PrefetchHooks Function({
            bool courseTermCourseRowsRefs,
            bool courseInstructorCourseRowsRefs,
            bool courseOfferingRowsRefs,
            bool courseAudienceRowsRefs,
            bool courseMeetingRuleRowsRefs,
            bool courseOccurrenceRowsRefs,
          })
        > {
  $$CourseCatalogRowsTableTableManager(
    _$AppDatabase db,
    $CourseCatalogRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseCatalogRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseCatalogRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseCatalogRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> catalogKey = const Value.absent(),
                Value<String> courseNo = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<double?> credits = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseCatalogRowsCompanion(
                id: id,
                catalogKey: catalogKey,
                courseNo: courseNo,
                courseName: courseName,
                credits: credits,
                searchText: searchText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String catalogKey,
                required String courseNo,
                required String courseName,
                Value<double?> credits = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseCatalogRowsCompanion.insert(
                id: id,
                catalogKey: catalogKey,
                courseNo: courseNo,
                courseName: courseName,
                credits: credits,
                searchText: searchText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseCatalogRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                courseTermCourseRowsRefs = false,
                courseInstructorCourseRowsRefs = false,
                courseOfferingRowsRefs = false,
                courseAudienceRowsRefs = false,
                courseMeetingRuleRowsRefs = false,
                courseOccurrenceRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (courseTermCourseRowsRefs) db.courseTermCourseRows,
                    if (courseInstructorCourseRowsRefs)
                      db.courseInstructorCourseRows,
                    if (courseOfferingRowsRefs) db.courseOfferingRows,
                    if (courseAudienceRowsRefs) db.courseAudienceRows,
                    if (courseMeetingRuleRowsRefs) db.courseMeetingRuleRows,
                    if (courseOccurrenceRowsRefs) db.courseOccurrenceRows,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (courseTermCourseRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseCatalogRowsTableReferences
                              ._courseTermCourseRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseCatalogRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseTermCourseRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.catalogId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseInstructorCourseRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseCatalogRowsTableReferences
                              ._courseInstructorCourseRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseCatalogRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseInstructorCourseRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.catalogId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseOfferingRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseCatalogRowsTableReferences
                              ._courseOfferingRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseCatalogRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseOfferingRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.catalogId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseAudienceRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseCatalogRowsTableReferences
                              ._courseAudienceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseCatalogRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseAudienceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.catalogId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseMeetingRuleRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseCatalogRowsTableReferences
                              ._courseMeetingRuleRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseCatalogRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseMeetingRuleRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.catalogId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseOccurrenceRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseCatalogRowsTableReferences
                              ._courseOccurrenceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseCatalogRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseOccurrenceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.catalogId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CourseCatalogRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseCatalogRowsTable,
      CourseCatalogRow,
      $$CourseCatalogRowsTableFilterComposer,
      $$CourseCatalogRowsTableOrderingComposer,
      $$CourseCatalogRowsTableAnnotationComposer,
      $$CourseCatalogRowsTableCreateCompanionBuilder,
      $$CourseCatalogRowsTableUpdateCompanionBuilder,
      (CourseCatalogRow, $$CourseCatalogRowsTableReferences),
      CourseCatalogRow,
      PrefetchHooks Function({
        bool courseTermCourseRowsRefs,
        bool courseInstructorCourseRowsRefs,
        bool courseOfferingRowsRefs,
        bool courseAudienceRowsRefs,
        bool courseMeetingRuleRowsRefs,
        bool courseOccurrenceRowsRefs,
      })
    >;
typedef $$CourseTermCourseRowsTableCreateCompanionBuilder =
    CourseTermCourseRowsCompanion Function({
      required String id,
      required String termKey,
      required String catalogId,
      required String courseNo,
      required String courseName,
      Value<String> openCollege,
      Value<double?> credits,
      Value<String> courseNature,
      Value<String> courseCategory,
      Value<String> openType,
      Value<int> teachingClassCount,
      Value<String> teacherSummary,
      Value<String> weekdaySummary,
      Value<String> searchText,
      Value<int> rowid,
    });
typedef $$CourseTermCourseRowsTableUpdateCompanionBuilder =
    CourseTermCourseRowsCompanion Function({
      Value<String> id,
      Value<String> termKey,
      Value<String> catalogId,
      Value<String> courseNo,
      Value<String> courseName,
      Value<String> openCollege,
      Value<double?> credits,
      Value<String> courseNature,
      Value<String> courseCategory,
      Value<String> openType,
      Value<int> teachingClassCount,
      Value<String> teacherSummary,
      Value<String> weekdaySummary,
      Value<String> searchText,
      Value<int> rowid,
    });

final class $$CourseTermCourseRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CourseTermCourseRowsTable,
          CourseTermCourseRow
        > {
  $$CourseTermCourseRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SchoolTimetableTermRowsTable _termKeyTable(_$AppDatabase db) =>
      db.schoolTimetableTermRows.createAlias(
        $_aliasNameGenerator(
          db.courseTermCourseRows.termKey,
          db.schoolTimetableTermRows.termKey,
        ),
      );

  $$SchoolTimetableTermRowsTableProcessedTableManager get termKey {
    final $_column = $_itemColumn<String>('term_key')!;

    final manager = $$SchoolTimetableTermRowsTableTableManager(
      $_db,
      $_db.schoolTimetableTermRows,
    ).filter((f) => f.termKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseCatalogRowsTable _catalogIdTable(_$AppDatabase db) =>
      db.courseCatalogRows.createAlias(
        $_aliasNameGenerator(
          db.courseTermCourseRows.catalogId,
          db.courseCatalogRows.id,
        ),
      );

  $$CourseCatalogRowsTableProcessedTableManager get catalogId {
    final $_column = $_itemColumn<String>('catalog_id')!;

    final manager = $$CourseCatalogRowsTableTableManager(
      $_db,
      $_db.courseCatalogRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CourseOfferingRowsTable, List<CourseOfferingRow>>
  _courseOfferingRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseOfferingRows,
        aliasName: $_aliasNameGenerator(
          db.courseTermCourseRows.id,
          db.courseOfferingRows.termCourseId,
        ),
      );

  $$CourseOfferingRowsTableProcessedTableManager get courseOfferingRowsRefs {
    final manager = $$CourseOfferingRowsTableTableManager(
      $_db,
      $_db.courseOfferingRows,
    ).filter((f) => f.termCourseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseOfferingRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CourseAudienceRowsTable, List<CourseAudienceRow>>
  _courseAudienceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseAudienceRows,
        aliasName: $_aliasNameGenerator(
          db.courseTermCourseRows.id,
          db.courseAudienceRows.termCourseId,
        ),
      );

  $$CourseAudienceRowsTableProcessedTableManager get courseAudienceRowsRefs {
    final manager = $$CourseAudienceRowsTableTableManager(
      $_db,
      $_db.courseAudienceRows,
    ).filter((f) => f.termCourseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseAudienceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CourseMeetingRuleRowsTable,
    List<CourseMeetingRuleRow>
  >
  _courseMeetingRuleRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseMeetingRuleRows,
        aliasName: $_aliasNameGenerator(
          db.courseTermCourseRows.id,
          db.courseMeetingRuleRows.termCourseId,
        ),
      );

  $$CourseMeetingRuleRowsTableProcessedTableManager
  get courseMeetingRuleRowsRefs {
    final manager = $$CourseMeetingRuleRowsTableTableManager(
      $_db,
      $_db.courseMeetingRuleRows,
    ).filter((f) => f.termCourseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseMeetingRuleRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CourseOccurrenceRowsTable,
    List<CourseOccurrenceRow>
  >
  _courseOccurrenceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseOccurrenceRows,
        aliasName: $_aliasNameGenerator(
          db.courseTermCourseRows.id,
          db.courseOccurrenceRows.termCourseId,
        ),
      );

  $$CourseOccurrenceRowsTableProcessedTableManager
  get courseOccurrenceRowsRefs {
    final manager = $$CourseOccurrenceRowsTableTableManager(
      $_db,
      $_db.courseOccurrenceRows,
    ).filter((f) => f.termCourseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseOccurrenceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CourseTermCourseRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseTermCourseRowsTable> {
  $$CourseTermCourseRowsTableFilterComposer({
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

  ColumnFilters<String> get courseNo => $composableBuilder(
    column: $table.courseNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openCollege => $composableBuilder(
    column: $table.openCollege,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseCategory => $composableBuilder(
    column: $table.courseCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openType => $composableBuilder(
    column: $table.openType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get teachingClassCount => $composableBuilder(
    column: $table.teachingClassCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherSummary => $composableBuilder(
    column: $table.teacherSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekdaySummary => $composableBuilder(
    column: $table.weekdaySummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  $$SchoolTimetableTermRowsTableFilterComposer get termKey {
    final $$SchoolTimetableTermRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableFilterComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableFilterComposer get catalogId {
    final $$CourseCatalogRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> courseOfferingRowsRefs(
    Expression<bool> Function($$CourseOfferingRowsTableFilterComposer f) f,
  ) {
    final $$CourseOfferingRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseOfferingRows,
      getReferencedColumn: (t) => t.termCourseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOfferingRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOfferingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseAudienceRowsRefs(
    Expression<bool> Function($$CourseAudienceRowsTableFilterComposer f) f,
  ) {
    final $$CourseAudienceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseAudienceRows,
      getReferencedColumn: (t) => t.termCourseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseAudienceRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseAudienceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseMeetingRuleRowsRefs(
    Expression<bool> Function($$CourseMeetingRuleRowsTableFilterComposer f) f,
  ) {
    final $$CourseMeetingRuleRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.termCourseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableFilterComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> courseOccurrenceRowsRefs(
    Expression<bool> Function($$CourseOccurrenceRowsTableFilterComposer f) f,
  ) {
    final $$CourseOccurrenceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseOccurrenceRows,
      getReferencedColumn: (t) => t.termCourseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOccurrenceRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOccurrenceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseTermCourseRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseTermCourseRowsTable> {
  $$CourseTermCourseRowsTableOrderingComposer({
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

  ColumnOrderings<String> get courseNo => $composableBuilder(
    column: $table.courseNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openCollege => $composableBuilder(
    column: $table.openCollege,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseCategory => $composableBuilder(
    column: $table.courseCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openType => $composableBuilder(
    column: $table.openType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get teachingClassCount => $composableBuilder(
    column: $table.teachingClassCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherSummary => $composableBuilder(
    column: $table.teacherSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdaySummary => $composableBuilder(
    column: $table.weekdaySummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchoolTimetableTermRowsTableOrderingComposer get termKey {
    final $$SchoolTimetableTermRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableOrderingComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableOrderingComposer get catalogId {
    final $$CourseCatalogRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableOrderingComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseTermCourseRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseTermCourseRowsTable> {
  $$CourseTermCourseRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseNo =>
      $composableBuilder(column: $table.courseNo, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openCollege => $composableBuilder(
    column: $table.openCollege,
    builder: (column) => column,
  );

  GeneratedColumn<double> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseCategory => $composableBuilder(
    column: $table.courseCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openType =>
      $composableBuilder(column: $table.openType, builder: (column) => column);

  GeneratedColumn<int> get teachingClassCount => $composableBuilder(
    column: $table.teachingClassCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teacherSummary => $composableBuilder(
    column: $table.teacherSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekdaySummary => $composableBuilder(
    column: $table.weekdaySummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  $$SchoolTimetableTermRowsTableAnnotationComposer get termKey {
    final $$SchoolTimetableTermRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableAnnotationComposer get catalogId {
    final $$CourseCatalogRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogId,
          referencedTable: $db.courseCatalogRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseCatalogRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseCatalogRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> courseOfferingRowsRefs<T extends Object>(
    Expression<T> Function($$CourseOfferingRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseOfferingRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseOfferingRows,
          getReferencedColumn: (t) => t.termCourseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOfferingRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOfferingRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseAudienceRowsRefs<T extends Object>(
    Expression<T> Function($$CourseAudienceRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseAudienceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseAudienceRows,
          getReferencedColumn: (t) => t.termCourseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseAudienceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseAudienceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseMeetingRuleRowsRefs<T extends Object>(
    Expression<T> Function($$CourseMeetingRuleRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseMeetingRuleRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.termCourseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseOccurrenceRowsRefs<T extends Object>(
    Expression<T> Function($$CourseOccurrenceRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseOccurrenceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseOccurrenceRows,
          getReferencedColumn: (t) => t.termCourseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOccurrenceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOccurrenceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CourseTermCourseRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseTermCourseRowsTable,
          CourseTermCourseRow,
          $$CourseTermCourseRowsTableFilterComposer,
          $$CourseTermCourseRowsTableOrderingComposer,
          $$CourseTermCourseRowsTableAnnotationComposer,
          $$CourseTermCourseRowsTableCreateCompanionBuilder,
          $$CourseTermCourseRowsTableUpdateCompanionBuilder,
          (CourseTermCourseRow, $$CourseTermCourseRowsTableReferences),
          CourseTermCourseRow,
          PrefetchHooks Function({
            bool termKey,
            bool catalogId,
            bool courseOfferingRowsRefs,
            bool courseAudienceRowsRefs,
            bool courseMeetingRuleRowsRefs,
            bool courseOccurrenceRowsRefs,
          })
        > {
  $$CourseTermCourseRowsTableTableManager(
    _$AppDatabase db,
    $CourseTermCourseRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseTermCourseRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseTermCourseRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CourseTermCourseRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> termKey = const Value.absent(),
                Value<String> catalogId = const Value.absent(),
                Value<String> courseNo = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<String> openCollege = const Value.absent(),
                Value<double?> credits = const Value.absent(),
                Value<String> courseNature = const Value.absent(),
                Value<String> courseCategory = const Value.absent(),
                Value<String> openType = const Value.absent(),
                Value<int> teachingClassCount = const Value.absent(),
                Value<String> teacherSummary = const Value.absent(),
                Value<String> weekdaySummary = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseTermCourseRowsCompanion(
                id: id,
                termKey: termKey,
                catalogId: catalogId,
                courseNo: courseNo,
                courseName: courseName,
                openCollege: openCollege,
                credits: credits,
                courseNature: courseNature,
                courseCategory: courseCategory,
                openType: openType,
                teachingClassCount: teachingClassCount,
                teacherSummary: teacherSummary,
                weekdaySummary: weekdaySummary,
                searchText: searchText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String termKey,
                required String catalogId,
                required String courseNo,
                required String courseName,
                Value<String> openCollege = const Value.absent(),
                Value<double?> credits = const Value.absent(),
                Value<String> courseNature = const Value.absent(),
                Value<String> courseCategory = const Value.absent(),
                Value<String> openType = const Value.absent(),
                Value<int> teachingClassCount = const Value.absent(),
                Value<String> teacherSummary = const Value.absent(),
                Value<String> weekdaySummary = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseTermCourseRowsCompanion.insert(
                id: id,
                termKey: termKey,
                catalogId: catalogId,
                courseNo: courseNo,
                courseName: courseName,
                openCollege: openCollege,
                credits: credits,
                courseNature: courseNature,
                courseCategory: courseCategory,
                openType: openType,
                teachingClassCount: teachingClassCount,
                teacherSummary: teacherSummary,
                weekdaySummary: weekdaySummary,
                searchText: searchText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseTermCourseRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                termKey = false,
                catalogId = false,
                courseOfferingRowsRefs = false,
                courseAudienceRowsRefs = false,
                courseMeetingRuleRowsRefs = false,
                courseOccurrenceRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (courseOfferingRowsRefs) db.courseOfferingRows,
                    if (courseAudienceRowsRefs) db.courseAudienceRows,
                    if (courseMeetingRuleRowsRefs) db.courseMeetingRuleRows,
                    if (courseOccurrenceRowsRefs) db.courseOccurrenceRows,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (termKey) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termKey,
                                    referencedTable:
                                        $$CourseTermCourseRowsTableReferences
                                            ._termKeyTable(db),
                                    referencedColumn:
                                        $$CourseTermCourseRowsTableReferences
                                            ._termKeyTable(db)
                                            .termKey,
                                  )
                                  as T;
                        }
                        if (catalogId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.catalogId,
                                    referencedTable:
                                        $$CourseTermCourseRowsTableReferences
                                            ._catalogIdTable(db),
                                    referencedColumn:
                                        $$CourseTermCourseRowsTableReferences
                                            ._catalogIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (courseOfferingRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseTermCourseRowsTableReferences
                              ._courseOfferingRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseTermCourseRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseOfferingRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.termCourseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseAudienceRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseTermCourseRowsTableReferences
                              ._courseAudienceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseTermCourseRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseAudienceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.termCourseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseMeetingRuleRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseTermCourseRowsTableReferences
                              ._courseMeetingRuleRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseTermCourseRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseMeetingRuleRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.termCourseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseOccurrenceRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseTermCourseRowsTableReferences
                              ._courseOccurrenceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseTermCourseRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseOccurrenceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.termCourseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CourseTermCourseRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseTermCourseRowsTable,
      CourseTermCourseRow,
      $$CourseTermCourseRowsTableFilterComposer,
      $$CourseTermCourseRowsTableOrderingComposer,
      $$CourseTermCourseRowsTableAnnotationComposer,
      $$CourseTermCourseRowsTableCreateCompanionBuilder,
      $$CourseTermCourseRowsTableUpdateCompanionBuilder,
      (CourseTermCourseRow, $$CourseTermCourseRowsTableReferences),
      CourseTermCourseRow,
      PrefetchHooks Function({
        bool termKey,
        bool catalogId,
        bool courseOfferingRowsRefs,
        bool courseAudienceRowsRefs,
        bool courseMeetingRuleRowsRefs,
        bool courseOccurrenceRowsRefs,
      })
    >;
typedef $$CourseInstructorCourseRowsTableCreateCompanionBuilder =
    CourseInstructorCourseRowsCompanion Function({
      required String id,
      required String catalogId,
      required String courseNo,
      required String courseName,
      Value<double?> credits,
      Value<String> instructorName,
      Value<String> instructorNameKey,
      Value<int> offeringCount,
      Value<String> latestTermKey,
      Value<String> latestOpenCollege,
      Value<String> latestTeachingTitle,
      Value<String> searchText,
      Value<int> rowid,
    });
typedef $$CourseInstructorCourseRowsTableUpdateCompanionBuilder =
    CourseInstructorCourseRowsCompanion Function({
      Value<String> id,
      Value<String> catalogId,
      Value<String> courseNo,
      Value<String> courseName,
      Value<double?> credits,
      Value<String> instructorName,
      Value<String> instructorNameKey,
      Value<int> offeringCount,
      Value<String> latestTermKey,
      Value<String> latestOpenCollege,
      Value<String> latestTeachingTitle,
      Value<String> searchText,
      Value<int> rowid,
    });

final class $$CourseInstructorCourseRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CourseInstructorCourseRowsTable,
          CourseInstructorCourseRow
        > {
  $$CourseInstructorCourseRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CourseCatalogRowsTable _catalogIdTable(_$AppDatabase db) =>
      db.courseCatalogRows.createAlias(
        $_aliasNameGenerator(
          db.courseInstructorCourseRows.catalogId,
          db.courseCatalogRows.id,
        ),
      );

  $$CourseCatalogRowsTableProcessedTableManager get catalogId {
    final $_column = $_itemColumn<String>('catalog_id')!;

    final manager = $$CourseCatalogRowsTableTableManager(
      $_db,
      $_db.courseCatalogRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CourseOfferingRowsTable, List<CourseOfferingRow>>
  _courseOfferingRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseOfferingRows,
        aliasName: $_aliasNameGenerator(
          db.courseInstructorCourseRows.id,
          db.courseOfferingRows.instructorCourseId,
        ),
      );

  $$CourseOfferingRowsTableProcessedTableManager get courseOfferingRowsRefs {
    final manager =
        $$CourseOfferingRowsTableTableManager(
          $_db,
          $_db.courseOfferingRows,
        ).filter(
          (f) => f.instructorCourseId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _courseOfferingRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CourseInstructorCourseRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseInstructorCourseRowsTable> {
  $$CourseInstructorCourseRowsTableFilterComposer({
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

  ColumnFilters<String> get courseNo => $composableBuilder(
    column: $table.courseNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructorName => $composableBuilder(
    column: $table.instructorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructorNameKey => $composableBuilder(
    column: $table.instructorNameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offeringCount => $composableBuilder(
    column: $table.offeringCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestTermKey => $composableBuilder(
    column: $table.latestTermKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestOpenCollege => $composableBuilder(
    column: $table.latestOpenCollege,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestTeachingTitle => $composableBuilder(
    column: $table.latestTeachingTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  $$CourseCatalogRowsTableFilterComposer get catalogId {
    final $$CourseCatalogRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> courseOfferingRowsRefs(
    Expression<bool> Function($$CourseOfferingRowsTableFilterComposer f) f,
  ) {
    final $$CourseOfferingRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseOfferingRows,
      getReferencedColumn: (t) => t.instructorCourseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOfferingRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOfferingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseInstructorCourseRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseInstructorCourseRowsTable> {
  $$CourseInstructorCourseRowsTableOrderingComposer({
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

  ColumnOrderings<String> get courseNo => $composableBuilder(
    column: $table.courseNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructorName => $composableBuilder(
    column: $table.instructorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructorNameKey => $composableBuilder(
    column: $table.instructorNameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offeringCount => $composableBuilder(
    column: $table.offeringCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestTermKey => $composableBuilder(
    column: $table.latestTermKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestOpenCollege => $composableBuilder(
    column: $table.latestOpenCollege,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestTeachingTitle => $composableBuilder(
    column: $table.latestTeachingTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  $$CourseCatalogRowsTableOrderingComposer get catalogId {
    final $$CourseCatalogRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableOrderingComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseInstructorCourseRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseInstructorCourseRowsTable> {
  $$CourseInstructorCourseRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseNo =>
      $composableBuilder(column: $table.courseNo, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<String> get instructorName => $composableBuilder(
    column: $table.instructorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructorNameKey => $composableBuilder(
    column: $table.instructorNameKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get offeringCount => $composableBuilder(
    column: $table.offeringCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get latestTermKey => $composableBuilder(
    column: $table.latestTermKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get latestOpenCollege => $composableBuilder(
    column: $table.latestOpenCollege,
    builder: (column) => column,
  );

  GeneratedColumn<String> get latestTeachingTitle => $composableBuilder(
    column: $table.latestTeachingTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  $$CourseCatalogRowsTableAnnotationComposer get catalogId {
    final $$CourseCatalogRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogId,
          referencedTable: $db.courseCatalogRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseCatalogRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseCatalogRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> courseOfferingRowsRefs<T extends Object>(
    Expression<T> Function($$CourseOfferingRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseOfferingRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseOfferingRows,
          getReferencedColumn: (t) => t.instructorCourseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOfferingRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOfferingRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CourseInstructorCourseRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseInstructorCourseRowsTable,
          CourseInstructorCourseRow,
          $$CourseInstructorCourseRowsTableFilterComposer,
          $$CourseInstructorCourseRowsTableOrderingComposer,
          $$CourseInstructorCourseRowsTableAnnotationComposer,
          $$CourseInstructorCourseRowsTableCreateCompanionBuilder,
          $$CourseInstructorCourseRowsTableUpdateCompanionBuilder,
          (
            CourseInstructorCourseRow,
            $$CourseInstructorCourseRowsTableReferences,
          ),
          CourseInstructorCourseRow,
          PrefetchHooks Function({bool catalogId, bool courseOfferingRowsRefs})
        > {
  $$CourseInstructorCourseRowsTableTableManager(
    _$AppDatabase db,
    $CourseInstructorCourseRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseInstructorCourseRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CourseInstructorCourseRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CourseInstructorCourseRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> catalogId = const Value.absent(),
                Value<String> courseNo = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<double?> credits = const Value.absent(),
                Value<String> instructorName = const Value.absent(),
                Value<String> instructorNameKey = const Value.absent(),
                Value<int> offeringCount = const Value.absent(),
                Value<String> latestTermKey = const Value.absent(),
                Value<String> latestOpenCollege = const Value.absent(),
                Value<String> latestTeachingTitle = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseInstructorCourseRowsCompanion(
                id: id,
                catalogId: catalogId,
                courseNo: courseNo,
                courseName: courseName,
                credits: credits,
                instructorName: instructorName,
                instructorNameKey: instructorNameKey,
                offeringCount: offeringCount,
                latestTermKey: latestTermKey,
                latestOpenCollege: latestOpenCollege,
                latestTeachingTitle: latestTeachingTitle,
                searchText: searchText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String catalogId,
                required String courseNo,
                required String courseName,
                Value<double?> credits = const Value.absent(),
                Value<String> instructorName = const Value.absent(),
                Value<String> instructorNameKey = const Value.absent(),
                Value<int> offeringCount = const Value.absent(),
                Value<String> latestTermKey = const Value.absent(),
                Value<String> latestOpenCollege = const Value.absent(),
                Value<String> latestTeachingTitle = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseInstructorCourseRowsCompanion.insert(
                id: id,
                catalogId: catalogId,
                courseNo: courseNo,
                courseName: courseName,
                credits: credits,
                instructorName: instructorName,
                instructorNameKey: instructorNameKey,
                offeringCount: offeringCount,
                latestTermKey: latestTermKey,
                latestOpenCollege: latestOpenCollege,
                latestTeachingTitle: latestTeachingTitle,
                searchText: searchText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseInstructorCourseRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({catalogId = false, courseOfferingRowsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (courseOfferingRowsRefs) db.courseOfferingRows,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (catalogId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.catalogId,
                                    referencedTable:
                                        $$CourseInstructorCourseRowsTableReferences
                                            ._catalogIdTable(db),
                                    referencedColumn:
                                        $$CourseInstructorCourseRowsTableReferences
                                            ._catalogIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (courseOfferingRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable:
                              $$CourseInstructorCourseRowsTableReferences
                                  ._courseOfferingRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseInstructorCourseRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseOfferingRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instructorCourseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CourseInstructorCourseRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseInstructorCourseRowsTable,
      CourseInstructorCourseRow,
      $$CourseInstructorCourseRowsTableFilterComposer,
      $$CourseInstructorCourseRowsTableOrderingComposer,
      $$CourseInstructorCourseRowsTableAnnotationComposer,
      $$CourseInstructorCourseRowsTableCreateCompanionBuilder,
      $$CourseInstructorCourseRowsTableUpdateCompanionBuilder,
      (CourseInstructorCourseRow, $$CourseInstructorCourseRowsTableReferences),
      CourseInstructorCourseRow,
      PrefetchHooks Function({bool catalogId, bool courseOfferingRowsRefs})
    >;
typedef $$CourseOfferingRowsTableCreateCompanionBuilder =
    CourseOfferingRowsCompanion Function({
      required String id,
      required String termKey,
      required String termCourseId,
      required String catalogId,
      required String instructorCourseId,
      required String sourceKey,
      Value<int> packageIndex,
      Value<String> sourceStatus,
      required String schoolYear,
      required String term,
      required String teachingClassName,
      required String courseNo,
      required String courseName,
      Value<String> openCollege,
      Value<String> planCollege,
      Value<double?> credits,
      Value<String> courseNature,
      Value<String> courseCategory,
      Value<String> openType,
      Value<String> grade,
      Value<String> major,
      Value<String> instructor,
      Value<String> title,
      Value<String> peopleRaw,
      Value<int?> theoryHours,
      Value<int?> computerHours,
      Value<int?> experimentHours,
      Value<int?> practiceHours,
      Value<String> sundayRaw,
      Value<String> mondayRaw,
      Value<String> tuesdayRaw,
      Value<String> wednesdayRaw,
      Value<String> thursdayRaw,
      Value<String> fridayRaw,
      Value<String> saturdayRaw,
      Value<String> remark,
      Value<String> otherTeachers,
      Value<String> textbook,
      Value<String> publisher,
      Value<String> openDepartmentCode,
      Value<String> collegeCode,
      Value<String> majorCode,
      Value<String> gradeCode,
      Value<String> schoolYearCode,
      Value<String> termCode,
      Value<String> courseCategoryCode,
      Value<String> conditionCode,
      Value<String> openTypeCode,
      Value<String> courseNatureCode,
      Value<String> note,
      Value<String> scheduleSummary,
      Value<String> weekdaySummary,
      Value<String> searchText,
      Value<String> originalFieldsJson,
      Value<int> rowid,
    });
typedef $$CourseOfferingRowsTableUpdateCompanionBuilder =
    CourseOfferingRowsCompanion Function({
      Value<String> id,
      Value<String> termKey,
      Value<String> termCourseId,
      Value<String> catalogId,
      Value<String> instructorCourseId,
      Value<String> sourceKey,
      Value<int> packageIndex,
      Value<String> sourceStatus,
      Value<String> schoolYear,
      Value<String> term,
      Value<String> teachingClassName,
      Value<String> courseNo,
      Value<String> courseName,
      Value<String> openCollege,
      Value<String> planCollege,
      Value<double?> credits,
      Value<String> courseNature,
      Value<String> courseCategory,
      Value<String> openType,
      Value<String> grade,
      Value<String> major,
      Value<String> instructor,
      Value<String> title,
      Value<String> peopleRaw,
      Value<int?> theoryHours,
      Value<int?> computerHours,
      Value<int?> experimentHours,
      Value<int?> practiceHours,
      Value<String> sundayRaw,
      Value<String> mondayRaw,
      Value<String> tuesdayRaw,
      Value<String> wednesdayRaw,
      Value<String> thursdayRaw,
      Value<String> fridayRaw,
      Value<String> saturdayRaw,
      Value<String> remark,
      Value<String> otherTeachers,
      Value<String> textbook,
      Value<String> publisher,
      Value<String> openDepartmentCode,
      Value<String> collegeCode,
      Value<String> majorCode,
      Value<String> gradeCode,
      Value<String> schoolYearCode,
      Value<String> termCode,
      Value<String> courseCategoryCode,
      Value<String> conditionCode,
      Value<String> openTypeCode,
      Value<String> courseNatureCode,
      Value<String> note,
      Value<String> scheduleSummary,
      Value<String> weekdaySummary,
      Value<String> searchText,
      Value<String> originalFieldsJson,
      Value<int> rowid,
    });

final class $$CourseOfferingRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CourseOfferingRowsTable,
          CourseOfferingRow
        > {
  $$CourseOfferingRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SchoolTimetableTermRowsTable _termKeyTable(_$AppDatabase db) =>
      db.schoolTimetableTermRows.createAlias(
        $_aliasNameGenerator(
          db.courseOfferingRows.termKey,
          db.schoolTimetableTermRows.termKey,
        ),
      );

  $$SchoolTimetableTermRowsTableProcessedTableManager get termKey {
    final $_column = $_itemColumn<String>('term_key')!;

    final manager = $$SchoolTimetableTermRowsTableTableManager(
      $_db,
      $_db.schoolTimetableTermRows,
    ).filter((f) => f.termKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseTermCourseRowsTable _termCourseIdTable(_$AppDatabase db) =>
      db.courseTermCourseRows.createAlias(
        $_aliasNameGenerator(
          db.courseOfferingRows.termCourseId,
          db.courseTermCourseRows.id,
        ),
      );

  $$CourseTermCourseRowsTableProcessedTableManager get termCourseId {
    final $_column = $_itemColumn<String>('term_course_id')!;

    final manager = $$CourseTermCourseRowsTableTableManager(
      $_db,
      $_db.courseTermCourseRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termCourseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseCatalogRowsTable _catalogIdTable(_$AppDatabase db) =>
      db.courseCatalogRows.createAlias(
        $_aliasNameGenerator(
          db.courseOfferingRows.catalogId,
          db.courseCatalogRows.id,
        ),
      );

  $$CourseCatalogRowsTableProcessedTableManager get catalogId {
    final $_column = $_itemColumn<String>('catalog_id')!;

    final manager = $$CourseCatalogRowsTableTableManager(
      $_db,
      $_db.courseCatalogRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseInstructorCourseRowsTable _instructorCourseIdTable(
    _$AppDatabase db,
  ) => db.courseInstructorCourseRows.createAlias(
    $_aliasNameGenerator(
      db.courseOfferingRows.instructorCourseId,
      db.courseInstructorCourseRows.id,
    ),
  );

  $$CourseInstructorCourseRowsTableProcessedTableManager
  get instructorCourseId {
    final $_column = $_itemColumn<String>('instructor_course_id')!;

    final manager = $$CourseInstructorCourseRowsTableTableManager(
      $_db,
      $_db.courseInstructorCourseRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instructorCourseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CourseAudienceRowsTable, List<CourseAudienceRow>>
  _courseAudienceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseAudienceRows,
        aliasName: $_aliasNameGenerator(
          db.courseOfferingRows.id,
          db.courseAudienceRows.offeringId,
        ),
      );

  $$CourseAudienceRowsTableProcessedTableManager get courseAudienceRowsRefs {
    final manager = $$CourseAudienceRowsTableTableManager(
      $_db,
      $_db.courseAudienceRows,
    ).filter((f) => f.offeringId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseAudienceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CourseMeetingRuleRowsTable,
    List<CourseMeetingRuleRow>
  >
  _courseMeetingRuleRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseMeetingRuleRows,
        aliasName: $_aliasNameGenerator(
          db.courseOfferingRows.id,
          db.courseMeetingRuleRows.offeringId,
        ),
      );

  $$CourseMeetingRuleRowsTableProcessedTableManager
  get courseMeetingRuleRowsRefs {
    final manager = $$CourseMeetingRuleRowsTableTableManager(
      $_db,
      $_db.courseMeetingRuleRows,
    ).filter((f) => f.offeringId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseMeetingRuleRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CourseOccurrenceRowsTable,
    List<CourseOccurrenceRow>
  >
  _courseOccurrenceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseOccurrenceRows,
        aliasName: $_aliasNameGenerator(
          db.courseOfferingRows.id,
          db.courseOccurrenceRows.offeringId,
        ),
      );

  $$CourseOccurrenceRowsTableProcessedTableManager
  get courseOccurrenceRowsRefs {
    final manager = $$CourseOccurrenceRowsTableTableManager(
      $_db,
      $_db.courseOccurrenceRows,
    ).filter((f) => f.offeringId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseOccurrenceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CourseOfferingRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseOfferingRowsTable> {
  $$CourseOfferingRowsTableFilterComposer({
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

  ColumnFilters<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get packageIndex => $composableBuilder(
    column: $table.packageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceStatus => $composableBuilder(
    column: $table.sourceStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teachingClassName => $composableBuilder(
    column: $table.teachingClassName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseNo => $composableBuilder(
    column: $table.courseNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openCollege => $composableBuilder(
    column: $table.openCollege,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planCollege => $composableBuilder(
    column: $table.planCollege,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseCategory => $composableBuilder(
    column: $table.courseCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openType => $composableBuilder(
    column: $table.openType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get major => $composableBuilder(
    column: $table.major,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructor => $composableBuilder(
    column: $table.instructor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peopleRaw => $composableBuilder(
    column: $table.peopleRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get theoryHours => $composableBuilder(
    column: $table.theoryHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get computerHours => $composableBuilder(
    column: $table.computerHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get experimentHours => $composableBuilder(
    column: $table.experimentHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get practiceHours => $composableBuilder(
    column: $table.practiceHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sundayRaw => $composableBuilder(
    column: $table.sundayRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mondayRaw => $composableBuilder(
    column: $table.mondayRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tuesdayRaw => $composableBuilder(
    column: $table.tuesdayRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wednesdayRaw => $composableBuilder(
    column: $table.wednesdayRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thursdayRaw => $composableBuilder(
    column: $table.thursdayRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fridayRaw => $composableBuilder(
    column: $table.fridayRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saturdayRaw => $composableBuilder(
    column: $table.saturdayRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherTeachers => $composableBuilder(
    column: $table.otherTeachers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textbook => $composableBuilder(
    column: $table.textbook,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openDepartmentCode => $composableBuilder(
    column: $table.openDepartmentCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collegeCode => $composableBuilder(
    column: $table.collegeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get majorCode => $composableBuilder(
    column: $table.majorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gradeCode => $composableBuilder(
    column: $table.gradeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolYearCode => $composableBuilder(
    column: $table.schoolYearCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get termCode => $composableBuilder(
    column: $table.termCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseCategoryCode => $composableBuilder(
    column: $table.courseCategoryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionCode => $composableBuilder(
    column: $table.conditionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openTypeCode => $composableBuilder(
    column: $table.openTypeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseNatureCode => $composableBuilder(
    column: $table.courseNatureCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleSummary => $composableBuilder(
    column: $table.scheduleSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekdaySummary => $composableBuilder(
    column: $table.weekdaySummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFieldsJson => $composableBuilder(
    column: $table.originalFieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$SchoolTimetableTermRowsTableFilterComposer get termKey {
    final $$SchoolTimetableTermRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableFilterComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseTermCourseRowsTableFilterComposer get termCourseId {
    final $$CourseTermCourseRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termCourseId,
      referencedTable: $db.courseTermCourseRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTermCourseRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseTermCourseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseCatalogRowsTableFilterComposer get catalogId {
    final $$CourseCatalogRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseInstructorCourseRowsTableFilterComposer get instructorCourseId {
    final $$CourseInstructorCourseRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.instructorCourseId,
          referencedTable: $db.courseInstructorCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseInstructorCourseRowsTableFilterComposer(
                $db: $db,
                $table: $db.courseInstructorCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> courseAudienceRowsRefs(
    Expression<bool> Function($$CourseAudienceRowsTableFilterComposer f) f,
  ) {
    final $$CourseAudienceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseAudienceRows,
      getReferencedColumn: (t) => t.offeringId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseAudienceRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseAudienceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseMeetingRuleRowsRefs(
    Expression<bool> Function($$CourseMeetingRuleRowsTableFilterComposer f) f,
  ) {
    final $$CourseMeetingRuleRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.offeringId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableFilterComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> courseOccurrenceRowsRefs(
    Expression<bool> Function($$CourseOccurrenceRowsTableFilterComposer f) f,
  ) {
    final $$CourseOccurrenceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseOccurrenceRows,
      getReferencedColumn: (t) => t.offeringId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOccurrenceRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOccurrenceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseOfferingRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseOfferingRowsTable> {
  $$CourseOfferingRowsTableOrderingComposer({
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

  ColumnOrderings<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get packageIndex => $composableBuilder(
    column: $table.packageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceStatus => $composableBuilder(
    column: $table.sourceStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teachingClassName => $composableBuilder(
    column: $table.teachingClassName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseNo => $composableBuilder(
    column: $table.courseNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openCollege => $composableBuilder(
    column: $table.openCollege,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planCollege => $composableBuilder(
    column: $table.planCollege,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseCategory => $composableBuilder(
    column: $table.courseCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openType => $composableBuilder(
    column: $table.openType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get major => $composableBuilder(
    column: $table.major,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructor => $composableBuilder(
    column: $table.instructor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peopleRaw => $composableBuilder(
    column: $table.peopleRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get theoryHours => $composableBuilder(
    column: $table.theoryHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get computerHours => $composableBuilder(
    column: $table.computerHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get experimentHours => $composableBuilder(
    column: $table.experimentHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get practiceHours => $composableBuilder(
    column: $table.practiceHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sundayRaw => $composableBuilder(
    column: $table.sundayRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mondayRaw => $composableBuilder(
    column: $table.mondayRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tuesdayRaw => $composableBuilder(
    column: $table.tuesdayRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wednesdayRaw => $composableBuilder(
    column: $table.wednesdayRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thursdayRaw => $composableBuilder(
    column: $table.thursdayRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fridayRaw => $composableBuilder(
    column: $table.fridayRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saturdayRaw => $composableBuilder(
    column: $table.saturdayRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherTeachers => $composableBuilder(
    column: $table.otherTeachers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textbook => $composableBuilder(
    column: $table.textbook,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openDepartmentCode => $composableBuilder(
    column: $table.openDepartmentCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collegeCode => $composableBuilder(
    column: $table.collegeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get majorCode => $composableBuilder(
    column: $table.majorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gradeCode => $composableBuilder(
    column: $table.gradeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolYearCode => $composableBuilder(
    column: $table.schoolYearCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get termCode => $composableBuilder(
    column: $table.termCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseCategoryCode => $composableBuilder(
    column: $table.courseCategoryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionCode => $composableBuilder(
    column: $table.conditionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openTypeCode => $composableBuilder(
    column: $table.openTypeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseNatureCode => $composableBuilder(
    column: $table.courseNatureCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleSummary => $composableBuilder(
    column: $table.scheduleSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdaySummary => $composableBuilder(
    column: $table.weekdaySummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFieldsJson => $composableBuilder(
    column: $table.originalFieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchoolTimetableTermRowsTableOrderingComposer get termKey {
    final $$SchoolTimetableTermRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableOrderingComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseTermCourseRowsTableOrderingComposer get termCourseId {
    final $$CourseTermCourseRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termCourseId,
          referencedTable: $db.courseTermCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTermCourseRowsTableOrderingComposer(
                $db: $db,
                $table: $db.courseTermCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableOrderingComposer get catalogId {
    final $$CourseCatalogRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableOrderingComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseInstructorCourseRowsTableOrderingComposer get instructorCourseId {
    final $$CourseInstructorCourseRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.instructorCourseId,
          referencedTable: $db.courseInstructorCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseInstructorCourseRowsTableOrderingComposer(
                $db: $db,
                $table: $db.courseInstructorCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CourseOfferingRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseOfferingRowsTable> {
  $$CourseOfferingRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceKey =>
      $composableBuilder(column: $table.sourceKey, builder: (column) => column);

  GeneratedColumn<int> get packageIndex => $composableBuilder(
    column: $table.packageIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceStatus => $composableBuilder(
    column: $table.sourceStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schoolYear => $composableBuilder(
    column: $table.schoolYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get teachingClassName => $composableBuilder(
    column: $table.teachingClassName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseNo =>
      $composableBuilder(column: $table.courseNo, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openCollege => $composableBuilder(
    column: $table.openCollege,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planCollege => $composableBuilder(
    column: $table.planCollege,
    builder: (column) => column,
  );

  GeneratedColumn<double> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseCategory => $composableBuilder(
    column: $table.courseCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openType =>
      $composableBuilder(column: $table.openType, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get major =>
      $composableBuilder(column: $table.major, builder: (column) => column);

  GeneratedColumn<String> get instructor => $composableBuilder(
    column: $table.instructor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get peopleRaw =>
      $composableBuilder(column: $table.peopleRaw, builder: (column) => column);

  GeneratedColumn<int> get theoryHours => $composableBuilder(
    column: $table.theoryHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get computerHours => $composableBuilder(
    column: $table.computerHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get experimentHours => $composableBuilder(
    column: $table.experimentHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get practiceHours => $composableBuilder(
    column: $table.practiceHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sundayRaw =>
      $composableBuilder(column: $table.sundayRaw, builder: (column) => column);

  GeneratedColumn<String> get mondayRaw =>
      $composableBuilder(column: $table.mondayRaw, builder: (column) => column);

  GeneratedColumn<String> get tuesdayRaw => $composableBuilder(
    column: $table.tuesdayRaw,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wednesdayRaw => $composableBuilder(
    column: $table.wednesdayRaw,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thursdayRaw => $composableBuilder(
    column: $table.thursdayRaw,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fridayRaw =>
      $composableBuilder(column: $table.fridayRaw, builder: (column) => column);

  GeneratedColumn<String> get saturdayRaw => $composableBuilder(
    column: $table.saturdayRaw,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<String> get otherTeachers => $composableBuilder(
    column: $table.otherTeachers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textbook =>
      $composableBuilder(column: $table.textbook, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get openDepartmentCode => $composableBuilder(
    column: $table.openDepartmentCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collegeCode => $composableBuilder(
    column: $table.collegeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get majorCode =>
      $composableBuilder(column: $table.majorCode, builder: (column) => column);

  GeneratedColumn<String> get gradeCode =>
      $composableBuilder(column: $table.gradeCode, builder: (column) => column);

  GeneratedColumn<String> get schoolYearCode => $composableBuilder(
    column: $table.schoolYearCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get termCode =>
      $composableBuilder(column: $table.termCode, builder: (column) => column);

  GeneratedColumn<String> get courseCategoryCode => $composableBuilder(
    column: $table.courseCategoryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conditionCode => $composableBuilder(
    column: $table.conditionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openTypeCode => $composableBuilder(
    column: $table.openTypeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseNatureCode => $composableBuilder(
    column: $table.courseNatureCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get scheduleSummary => $composableBuilder(
    column: $table.scheduleSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekdaySummary => $composableBuilder(
    column: $table.weekdaySummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalFieldsJson => $composableBuilder(
    column: $table.originalFieldsJson,
    builder: (column) => column,
  );

  $$SchoolTimetableTermRowsTableAnnotationComposer get termKey {
    final $$SchoolTimetableTermRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseTermCourseRowsTableAnnotationComposer get termCourseId {
    final $$CourseTermCourseRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termCourseId,
          referencedTable: $db.courseTermCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTermCourseRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseTermCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableAnnotationComposer get catalogId {
    final $$CourseCatalogRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogId,
          referencedTable: $db.courseCatalogRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseCatalogRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseCatalogRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseInstructorCourseRowsTableAnnotationComposer get instructorCourseId {
    final $$CourseInstructorCourseRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.instructorCourseId,
          referencedTable: $db.courseInstructorCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseInstructorCourseRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseInstructorCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> courseAudienceRowsRefs<T extends Object>(
    Expression<T> Function($$CourseAudienceRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseAudienceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseAudienceRows,
          getReferencedColumn: (t) => t.offeringId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseAudienceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseAudienceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseMeetingRuleRowsRefs<T extends Object>(
    Expression<T> Function($$CourseMeetingRuleRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseMeetingRuleRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.offeringId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> courseOccurrenceRowsRefs<T extends Object>(
    Expression<T> Function($$CourseOccurrenceRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseOccurrenceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseOccurrenceRows,
          getReferencedColumn: (t) => t.offeringId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOccurrenceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOccurrenceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CourseOfferingRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseOfferingRowsTable,
          CourseOfferingRow,
          $$CourseOfferingRowsTableFilterComposer,
          $$CourseOfferingRowsTableOrderingComposer,
          $$CourseOfferingRowsTableAnnotationComposer,
          $$CourseOfferingRowsTableCreateCompanionBuilder,
          $$CourseOfferingRowsTableUpdateCompanionBuilder,
          (CourseOfferingRow, $$CourseOfferingRowsTableReferences),
          CourseOfferingRow,
          PrefetchHooks Function({
            bool termKey,
            bool termCourseId,
            bool catalogId,
            bool instructorCourseId,
            bool courseAudienceRowsRefs,
            bool courseMeetingRuleRowsRefs,
            bool courseOccurrenceRowsRefs,
          })
        > {
  $$CourseOfferingRowsTableTableManager(
    _$AppDatabase db,
    $CourseOfferingRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseOfferingRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseOfferingRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseOfferingRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> termKey = const Value.absent(),
                Value<String> termCourseId = const Value.absent(),
                Value<String> catalogId = const Value.absent(),
                Value<String> instructorCourseId = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<int> packageIndex = const Value.absent(),
                Value<String> sourceStatus = const Value.absent(),
                Value<String> schoolYear = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String> teachingClassName = const Value.absent(),
                Value<String> courseNo = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<String> openCollege = const Value.absent(),
                Value<String> planCollege = const Value.absent(),
                Value<double?> credits = const Value.absent(),
                Value<String> courseNature = const Value.absent(),
                Value<String> courseCategory = const Value.absent(),
                Value<String> openType = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<String> major = const Value.absent(),
                Value<String> instructor = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> peopleRaw = const Value.absent(),
                Value<int?> theoryHours = const Value.absent(),
                Value<int?> computerHours = const Value.absent(),
                Value<int?> experimentHours = const Value.absent(),
                Value<int?> practiceHours = const Value.absent(),
                Value<String> sundayRaw = const Value.absent(),
                Value<String> mondayRaw = const Value.absent(),
                Value<String> tuesdayRaw = const Value.absent(),
                Value<String> wednesdayRaw = const Value.absent(),
                Value<String> thursdayRaw = const Value.absent(),
                Value<String> fridayRaw = const Value.absent(),
                Value<String> saturdayRaw = const Value.absent(),
                Value<String> remark = const Value.absent(),
                Value<String> otherTeachers = const Value.absent(),
                Value<String> textbook = const Value.absent(),
                Value<String> publisher = const Value.absent(),
                Value<String> openDepartmentCode = const Value.absent(),
                Value<String> collegeCode = const Value.absent(),
                Value<String> majorCode = const Value.absent(),
                Value<String> gradeCode = const Value.absent(),
                Value<String> schoolYearCode = const Value.absent(),
                Value<String> termCode = const Value.absent(),
                Value<String> courseCategoryCode = const Value.absent(),
                Value<String> conditionCode = const Value.absent(),
                Value<String> openTypeCode = const Value.absent(),
                Value<String> courseNatureCode = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> scheduleSummary = const Value.absent(),
                Value<String> weekdaySummary = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<String> originalFieldsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseOfferingRowsCompanion(
                id: id,
                termKey: termKey,
                termCourseId: termCourseId,
                catalogId: catalogId,
                instructorCourseId: instructorCourseId,
                sourceKey: sourceKey,
                packageIndex: packageIndex,
                sourceStatus: sourceStatus,
                schoolYear: schoolYear,
                term: term,
                teachingClassName: teachingClassName,
                courseNo: courseNo,
                courseName: courseName,
                openCollege: openCollege,
                planCollege: planCollege,
                credits: credits,
                courseNature: courseNature,
                courseCategory: courseCategory,
                openType: openType,
                grade: grade,
                major: major,
                instructor: instructor,
                title: title,
                peopleRaw: peopleRaw,
                theoryHours: theoryHours,
                computerHours: computerHours,
                experimentHours: experimentHours,
                practiceHours: practiceHours,
                sundayRaw: sundayRaw,
                mondayRaw: mondayRaw,
                tuesdayRaw: tuesdayRaw,
                wednesdayRaw: wednesdayRaw,
                thursdayRaw: thursdayRaw,
                fridayRaw: fridayRaw,
                saturdayRaw: saturdayRaw,
                remark: remark,
                otherTeachers: otherTeachers,
                textbook: textbook,
                publisher: publisher,
                openDepartmentCode: openDepartmentCode,
                collegeCode: collegeCode,
                majorCode: majorCode,
                gradeCode: gradeCode,
                schoolYearCode: schoolYearCode,
                termCode: termCode,
                courseCategoryCode: courseCategoryCode,
                conditionCode: conditionCode,
                openTypeCode: openTypeCode,
                courseNatureCode: courseNatureCode,
                note: note,
                scheduleSummary: scheduleSummary,
                weekdaySummary: weekdaySummary,
                searchText: searchText,
                originalFieldsJson: originalFieldsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String termKey,
                required String termCourseId,
                required String catalogId,
                required String instructorCourseId,
                required String sourceKey,
                Value<int> packageIndex = const Value.absent(),
                Value<String> sourceStatus = const Value.absent(),
                required String schoolYear,
                required String term,
                required String teachingClassName,
                required String courseNo,
                required String courseName,
                Value<String> openCollege = const Value.absent(),
                Value<String> planCollege = const Value.absent(),
                Value<double?> credits = const Value.absent(),
                Value<String> courseNature = const Value.absent(),
                Value<String> courseCategory = const Value.absent(),
                Value<String> openType = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<String> major = const Value.absent(),
                Value<String> instructor = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> peopleRaw = const Value.absent(),
                Value<int?> theoryHours = const Value.absent(),
                Value<int?> computerHours = const Value.absent(),
                Value<int?> experimentHours = const Value.absent(),
                Value<int?> practiceHours = const Value.absent(),
                Value<String> sundayRaw = const Value.absent(),
                Value<String> mondayRaw = const Value.absent(),
                Value<String> tuesdayRaw = const Value.absent(),
                Value<String> wednesdayRaw = const Value.absent(),
                Value<String> thursdayRaw = const Value.absent(),
                Value<String> fridayRaw = const Value.absent(),
                Value<String> saturdayRaw = const Value.absent(),
                Value<String> remark = const Value.absent(),
                Value<String> otherTeachers = const Value.absent(),
                Value<String> textbook = const Value.absent(),
                Value<String> publisher = const Value.absent(),
                Value<String> openDepartmentCode = const Value.absent(),
                Value<String> collegeCode = const Value.absent(),
                Value<String> majorCode = const Value.absent(),
                Value<String> gradeCode = const Value.absent(),
                Value<String> schoolYearCode = const Value.absent(),
                Value<String> termCode = const Value.absent(),
                Value<String> courseCategoryCode = const Value.absent(),
                Value<String> conditionCode = const Value.absent(),
                Value<String> openTypeCode = const Value.absent(),
                Value<String> courseNatureCode = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> scheduleSummary = const Value.absent(),
                Value<String> weekdaySummary = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<String> originalFieldsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseOfferingRowsCompanion.insert(
                id: id,
                termKey: termKey,
                termCourseId: termCourseId,
                catalogId: catalogId,
                instructorCourseId: instructorCourseId,
                sourceKey: sourceKey,
                packageIndex: packageIndex,
                sourceStatus: sourceStatus,
                schoolYear: schoolYear,
                term: term,
                teachingClassName: teachingClassName,
                courseNo: courseNo,
                courseName: courseName,
                openCollege: openCollege,
                planCollege: planCollege,
                credits: credits,
                courseNature: courseNature,
                courseCategory: courseCategory,
                openType: openType,
                grade: grade,
                major: major,
                instructor: instructor,
                title: title,
                peopleRaw: peopleRaw,
                theoryHours: theoryHours,
                computerHours: computerHours,
                experimentHours: experimentHours,
                practiceHours: practiceHours,
                sundayRaw: sundayRaw,
                mondayRaw: mondayRaw,
                tuesdayRaw: tuesdayRaw,
                wednesdayRaw: wednesdayRaw,
                thursdayRaw: thursdayRaw,
                fridayRaw: fridayRaw,
                saturdayRaw: saturdayRaw,
                remark: remark,
                otherTeachers: otherTeachers,
                textbook: textbook,
                publisher: publisher,
                openDepartmentCode: openDepartmentCode,
                collegeCode: collegeCode,
                majorCode: majorCode,
                gradeCode: gradeCode,
                schoolYearCode: schoolYearCode,
                termCode: termCode,
                courseCategoryCode: courseCategoryCode,
                conditionCode: conditionCode,
                openTypeCode: openTypeCode,
                courseNatureCode: courseNatureCode,
                note: note,
                scheduleSummary: scheduleSummary,
                weekdaySummary: weekdaySummary,
                searchText: searchText,
                originalFieldsJson: originalFieldsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseOfferingRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                termKey = false,
                termCourseId = false,
                catalogId = false,
                instructorCourseId = false,
                courseAudienceRowsRefs = false,
                courseMeetingRuleRowsRefs = false,
                courseOccurrenceRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (courseAudienceRowsRefs) db.courseAudienceRows,
                    if (courseMeetingRuleRowsRefs) db.courseMeetingRuleRows,
                    if (courseOccurrenceRowsRefs) db.courseOccurrenceRows,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (termKey) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termKey,
                                    referencedTable:
                                        $$CourseOfferingRowsTableReferences
                                            ._termKeyTable(db),
                                    referencedColumn:
                                        $$CourseOfferingRowsTableReferences
                                            ._termKeyTable(db)
                                            .termKey,
                                  )
                                  as T;
                        }
                        if (termCourseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termCourseId,
                                    referencedTable:
                                        $$CourseOfferingRowsTableReferences
                                            ._termCourseIdTable(db),
                                    referencedColumn:
                                        $$CourseOfferingRowsTableReferences
                                            ._termCourseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (catalogId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.catalogId,
                                    referencedTable:
                                        $$CourseOfferingRowsTableReferences
                                            ._catalogIdTable(db),
                                    referencedColumn:
                                        $$CourseOfferingRowsTableReferences
                                            ._catalogIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (instructorCourseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.instructorCourseId,
                                    referencedTable:
                                        $$CourseOfferingRowsTableReferences
                                            ._instructorCourseIdTable(db),
                                    referencedColumn:
                                        $$CourseOfferingRowsTableReferences
                                            ._instructorCourseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (courseAudienceRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseOfferingRowsTableReferences
                              ._courseAudienceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseOfferingRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseAudienceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.offeringId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseMeetingRuleRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseOfferingRowsTableReferences
                              ._courseMeetingRuleRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseOfferingRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseMeetingRuleRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.offeringId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseOccurrenceRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$CourseOfferingRowsTableReferences
                              ._courseOccurrenceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseOfferingRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseOccurrenceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.offeringId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CourseOfferingRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseOfferingRowsTable,
      CourseOfferingRow,
      $$CourseOfferingRowsTableFilterComposer,
      $$CourseOfferingRowsTableOrderingComposer,
      $$CourseOfferingRowsTableAnnotationComposer,
      $$CourseOfferingRowsTableCreateCompanionBuilder,
      $$CourseOfferingRowsTableUpdateCompanionBuilder,
      (CourseOfferingRow, $$CourseOfferingRowsTableReferences),
      CourseOfferingRow,
      PrefetchHooks Function({
        bool termKey,
        bool termCourseId,
        bool catalogId,
        bool instructorCourseId,
        bool courseAudienceRowsRefs,
        bool courseMeetingRuleRowsRefs,
        bool courseOccurrenceRowsRefs,
      })
    >;
typedef $$CourseAudienceRowsTableCreateCompanionBuilder =
    CourseAudienceRowsCompanion Function({
      required String id,
      required String termKey,
      required String offeringId,
      required String termCourseId,
      required String catalogId,
      Value<String> grade,
      Value<String> major,
      Value<String> planCollege,
      Value<String> courseNature,
      Value<String> courseNatureCode,
      Value<String> courseCategory,
      Value<String> courseCategoryCode,
      Value<String> openType,
      Value<String> openTypeCode,
      Value<String> conditionCode,
      Value<int> rowid,
    });
typedef $$CourseAudienceRowsTableUpdateCompanionBuilder =
    CourseAudienceRowsCompanion Function({
      Value<String> id,
      Value<String> termKey,
      Value<String> offeringId,
      Value<String> termCourseId,
      Value<String> catalogId,
      Value<String> grade,
      Value<String> major,
      Value<String> planCollege,
      Value<String> courseNature,
      Value<String> courseNatureCode,
      Value<String> courseCategory,
      Value<String> courseCategoryCode,
      Value<String> openType,
      Value<String> openTypeCode,
      Value<String> conditionCode,
      Value<int> rowid,
    });

final class $$CourseAudienceRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CourseAudienceRowsTable,
          CourseAudienceRow
        > {
  $$CourseAudienceRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SchoolTimetableTermRowsTable _termKeyTable(_$AppDatabase db) =>
      db.schoolTimetableTermRows.createAlias(
        $_aliasNameGenerator(
          db.courseAudienceRows.termKey,
          db.schoolTimetableTermRows.termKey,
        ),
      );

  $$SchoolTimetableTermRowsTableProcessedTableManager get termKey {
    final $_column = $_itemColumn<String>('term_key')!;

    final manager = $$SchoolTimetableTermRowsTableTableManager(
      $_db,
      $_db.schoolTimetableTermRows,
    ).filter((f) => f.termKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseOfferingRowsTable _offeringIdTable(_$AppDatabase db) =>
      db.courseOfferingRows.createAlias(
        $_aliasNameGenerator(
          db.courseAudienceRows.offeringId,
          db.courseOfferingRows.id,
        ),
      );

  $$CourseOfferingRowsTableProcessedTableManager get offeringId {
    final $_column = $_itemColumn<String>('offering_id')!;

    final manager = $$CourseOfferingRowsTableTableManager(
      $_db,
      $_db.courseOfferingRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_offeringIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseTermCourseRowsTable _termCourseIdTable(_$AppDatabase db) =>
      db.courseTermCourseRows.createAlias(
        $_aliasNameGenerator(
          db.courseAudienceRows.termCourseId,
          db.courseTermCourseRows.id,
        ),
      );

  $$CourseTermCourseRowsTableProcessedTableManager get termCourseId {
    final $_column = $_itemColumn<String>('term_course_id')!;

    final manager = $$CourseTermCourseRowsTableTableManager(
      $_db,
      $_db.courseTermCourseRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termCourseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseCatalogRowsTable _catalogIdTable(_$AppDatabase db) =>
      db.courseCatalogRows.createAlias(
        $_aliasNameGenerator(
          db.courseAudienceRows.catalogId,
          db.courseCatalogRows.id,
        ),
      );

  $$CourseCatalogRowsTableProcessedTableManager get catalogId {
    final $_column = $_itemColumn<String>('catalog_id')!;

    final manager = $$CourseCatalogRowsTableTableManager(
      $_db,
      $_db.courseCatalogRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CourseAudienceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseAudienceRowsTable> {
  $$CourseAudienceRowsTableFilterComposer({
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

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get major => $composableBuilder(
    column: $table.major,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planCollege => $composableBuilder(
    column: $table.planCollege,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseNatureCode => $composableBuilder(
    column: $table.courseNatureCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseCategory => $composableBuilder(
    column: $table.courseCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseCategoryCode => $composableBuilder(
    column: $table.courseCategoryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openType => $composableBuilder(
    column: $table.openType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openTypeCode => $composableBuilder(
    column: $table.openTypeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionCode => $composableBuilder(
    column: $table.conditionCode,
    builder: (column) => ColumnFilters(column),
  );

  $$SchoolTimetableTermRowsTableFilterComposer get termKey {
    final $$SchoolTimetableTermRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableFilterComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseOfferingRowsTableFilterComposer get offeringId {
    final $$CourseOfferingRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.offeringId,
      referencedTable: $db.courseOfferingRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOfferingRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOfferingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseTermCourseRowsTableFilterComposer get termCourseId {
    final $$CourseTermCourseRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termCourseId,
      referencedTable: $db.courseTermCourseRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTermCourseRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseTermCourseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseCatalogRowsTableFilterComposer get catalogId {
    final $$CourseCatalogRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseAudienceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseAudienceRowsTable> {
  $$CourseAudienceRowsTableOrderingComposer({
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

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get major => $composableBuilder(
    column: $table.major,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planCollege => $composableBuilder(
    column: $table.planCollege,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseNatureCode => $composableBuilder(
    column: $table.courseNatureCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseCategory => $composableBuilder(
    column: $table.courseCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseCategoryCode => $composableBuilder(
    column: $table.courseCategoryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openType => $composableBuilder(
    column: $table.openType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openTypeCode => $composableBuilder(
    column: $table.openTypeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionCode => $composableBuilder(
    column: $table.conditionCode,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchoolTimetableTermRowsTableOrderingComposer get termKey {
    final $$SchoolTimetableTermRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableOrderingComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseOfferingRowsTableOrderingComposer get offeringId {
    final $$CourseOfferingRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.offeringId,
      referencedTable: $db.courseOfferingRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOfferingRowsTableOrderingComposer(
            $db: $db,
            $table: $db.courseOfferingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseTermCourseRowsTableOrderingComposer get termCourseId {
    final $$CourseTermCourseRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termCourseId,
          referencedTable: $db.courseTermCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTermCourseRowsTableOrderingComposer(
                $db: $db,
                $table: $db.courseTermCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableOrderingComposer get catalogId {
    final $$CourseCatalogRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableOrderingComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseAudienceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseAudienceRowsTable> {
  $$CourseAudienceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get major =>
      $composableBuilder(column: $table.major, builder: (column) => column);

  GeneratedColumn<String> get planCollege => $composableBuilder(
    column: $table.planCollege,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseNature => $composableBuilder(
    column: $table.courseNature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseNatureCode => $composableBuilder(
    column: $table.courseNatureCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseCategory => $composableBuilder(
    column: $table.courseCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseCategoryCode => $composableBuilder(
    column: $table.courseCategoryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openType =>
      $composableBuilder(column: $table.openType, builder: (column) => column);

  GeneratedColumn<String> get openTypeCode => $composableBuilder(
    column: $table.openTypeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conditionCode => $composableBuilder(
    column: $table.conditionCode,
    builder: (column) => column,
  );

  $$SchoolTimetableTermRowsTableAnnotationComposer get termKey {
    final $$SchoolTimetableTermRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseOfferingRowsTableAnnotationComposer get offeringId {
    final $$CourseOfferingRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.offeringId,
          referencedTable: $db.courseOfferingRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOfferingRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOfferingRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseTermCourseRowsTableAnnotationComposer get termCourseId {
    final $$CourseTermCourseRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termCourseId,
          referencedTable: $db.courseTermCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTermCourseRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseTermCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableAnnotationComposer get catalogId {
    final $$CourseCatalogRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogId,
          referencedTable: $db.courseCatalogRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseCatalogRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseCatalogRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CourseAudienceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseAudienceRowsTable,
          CourseAudienceRow,
          $$CourseAudienceRowsTableFilterComposer,
          $$CourseAudienceRowsTableOrderingComposer,
          $$CourseAudienceRowsTableAnnotationComposer,
          $$CourseAudienceRowsTableCreateCompanionBuilder,
          $$CourseAudienceRowsTableUpdateCompanionBuilder,
          (CourseAudienceRow, $$CourseAudienceRowsTableReferences),
          CourseAudienceRow,
          PrefetchHooks Function({
            bool termKey,
            bool offeringId,
            bool termCourseId,
            bool catalogId,
          })
        > {
  $$CourseAudienceRowsTableTableManager(
    _$AppDatabase db,
    $CourseAudienceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseAudienceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseAudienceRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseAudienceRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> termKey = const Value.absent(),
                Value<String> offeringId = const Value.absent(),
                Value<String> termCourseId = const Value.absent(),
                Value<String> catalogId = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<String> major = const Value.absent(),
                Value<String> planCollege = const Value.absent(),
                Value<String> courseNature = const Value.absent(),
                Value<String> courseNatureCode = const Value.absent(),
                Value<String> courseCategory = const Value.absent(),
                Value<String> courseCategoryCode = const Value.absent(),
                Value<String> openType = const Value.absent(),
                Value<String> openTypeCode = const Value.absent(),
                Value<String> conditionCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseAudienceRowsCompanion(
                id: id,
                termKey: termKey,
                offeringId: offeringId,
                termCourseId: termCourseId,
                catalogId: catalogId,
                grade: grade,
                major: major,
                planCollege: planCollege,
                courseNature: courseNature,
                courseNatureCode: courseNatureCode,
                courseCategory: courseCategory,
                courseCategoryCode: courseCategoryCode,
                openType: openType,
                openTypeCode: openTypeCode,
                conditionCode: conditionCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String termKey,
                required String offeringId,
                required String termCourseId,
                required String catalogId,
                Value<String> grade = const Value.absent(),
                Value<String> major = const Value.absent(),
                Value<String> planCollege = const Value.absent(),
                Value<String> courseNature = const Value.absent(),
                Value<String> courseNatureCode = const Value.absent(),
                Value<String> courseCategory = const Value.absent(),
                Value<String> courseCategoryCode = const Value.absent(),
                Value<String> openType = const Value.absent(),
                Value<String> openTypeCode = const Value.absent(),
                Value<String> conditionCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseAudienceRowsCompanion.insert(
                id: id,
                termKey: termKey,
                offeringId: offeringId,
                termCourseId: termCourseId,
                catalogId: catalogId,
                grade: grade,
                major: major,
                planCollege: planCollege,
                courseNature: courseNature,
                courseNatureCode: courseNatureCode,
                courseCategory: courseCategory,
                courseCategoryCode: courseCategoryCode,
                openType: openType,
                openTypeCode: openTypeCode,
                conditionCode: conditionCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseAudienceRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                termKey = false,
                offeringId = false,
                termCourseId = false,
                catalogId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (termKey) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termKey,
                                    referencedTable:
                                        $$CourseAudienceRowsTableReferences
                                            ._termKeyTable(db),
                                    referencedColumn:
                                        $$CourseAudienceRowsTableReferences
                                            ._termKeyTable(db)
                                            .termKey,
                                  )
                                  as T;
                        }
                        if (offeringId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.offeringId,
                                    referencedTable:
                                        $$CourseAudienceRowsTableReferences
                                            ._offeringIdTable(db),
                                    referencedColumn:
                                        $$CourseAudienceRowsTableReferences
                                            ._offeringIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (termCourseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termCourseId,
                                    referencedTable:
                                        $$CourseAudienceRowsTableReferences
                                            ._termCourseIdTable(db),
                                    referencedColumn:
                                        $$CourseAudienceRowsTableReferences
                                            ._termCourseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (catalogId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.catalogId,
                                    referencedTable:
                                        $$CourseAudienceRowsTableReferences
                                            ._catalogIdTable(db),
                                    referencedColumn:
                                        $$CourseAudienceRowsTableReferences
                                            ._catalogIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$CourseAudienceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseAudienceRowsTable,
      CourseAudienceRow,
      $$CourseAudienceRowsTableFilterComposer,
      $$CourseAudienceRowsTableOrderingComposer,
      $$CourseAudienceRowsTableAnnotationComposer,
      $$CourseAudienceRowsTableCreateCompanionBuilder,
      $$CourseAudienceRowsTableUpdateCompanionBuilder,
      (CourseAudienceRow, $$CourseAudienceRowsTableReferences),
      CourseAudienceRow,
      PrefetchHooks Function({
        bool termKey,
        bool offeringId,
        bool termCourseId,
        bool catalogId,
      })
    >;
typedef $$CourseSourceRowsTableCreateCompanionBuilder =
    CourseSourceRowsCompanion Function({
      required String id,
      required String termKey,
      Value<String> termCourseId,
      Value<String> offeringId,
      Value<String> sourceKey,
      Value<int> packageIndex,
      Value<String> sourceStatus,
      Value<String> originalFieldsJson,
      Value<int> rowid,
    });
typedef $$CourseSourceRowsTableUpdateCompanionBuilder =
    CourseSourceRowsCompanion Function({
      Value<String> id,
      Value<String> termKey,
      Value<String> termCourseId,
      Value<String> offeringId,
      Value<String> sourceKey,
      Value<int> packageIndex,
      Value<String> sourceStatus,
      Value<String> originalFieldsJson,
      Value<int> rowid,
    });

final class $$CourseSourceRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CourseSourceRowsTable, CourseSourceRow> {
  $$CourseSourceRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SchoolTimetableTermRowsTable _termKeyTable(_$AppDatabase db) =>
      db.schoolTimetableTermRows.createAlias(
        $_aliasNameGenerator(
          db.courseSourceRows.termKey,
          db.schoolTimetableTermRows.termKey,
        ),
      );

  $$SchoolTimetableTermRowsTableProcessedTableManager get termKey {
    final $_column = $_itemColumn<String>('term_key')!;

    final manager = $$SchoolTimetableTermRowsTableTableManager(
      $_db,
      $_db.schoolTimetableTermRows,
    ).filter((f) => f.termKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CourseSourceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseSourceRowsTable> {
  $$CourseSourceRowsTableFilterComposer({
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

  ColumnFilters<String> get termCourseId => $composableBuilder(
    column: $table.termCourseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get offeringId => $composableBuilder(
    column: $table.offeringId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get packageIndex => $composableBuilder(
    column: $table.packageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceStatus => $composableBuilder(
    column: $table.sourceStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFieldsJson => $composableBuilder(
    column: $table.originalFieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$SchoolTimetableTermRowsTableFilterComposer get termKey {
    final $$SchoolTimetableTermRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableFilterComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CourseSourceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseSourceRowsTable> {
  $$CourseSourceRowsTableOrderingComposer({
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

  ColumnOrderings<String> get termCourseId => $composableBuilder(
    column: $table.termCourseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get offeringId => $composableBuilder(
    column: $table.offeringId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get packageIndex => $composableBuilder(
    column: $table.packageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceStatus => $composableBuilder(
    column: $table.sourceStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFieldsJson => $composableBuilder(
    column: $table.originalFieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchoolTimetableTermRowsTableOrderingComposer get termKey {
    final $$SchoolTimetableTermRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableOrderingComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CourseSourceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseSourceRowsTable> {
  $$CourseSourceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get termCourseId => $composableBuilder(
    column: $table.termCourseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get offeringId => $composableBuilder(
    column: $table.offeringId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceKey =>
      $composableBuilder(column: $table.sourceKey, builder: (column) => column);

  GeneratedColumn<int> get packageIndex => $composableBuilder(
    column: $table.packageIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceStatus => $composableBuilder(
    column: $table.sourceStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalFieldsJson => $composableBuilder(
    column: $table.originalFieldsJson,
    builder: (column) => column,
  );

  $$SchoolTimetableTermRowsTableAnnotationComposer get termKey {
    final $$SchoolTimetableTermRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CourseSourceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseSourceRowsTable,
          CourseSourceRow,
          $$CourseSourceRowsTableFilterComposer,
          $$CourseSourceRowsTableOrderingComposer,
          $$CourseSourceRowsTableAnnotationComposer,
          $$CourseSourceRowsTableCreateCompanionBuilder,
          $$CourseSourceRowsTableUpdateCompanionBuilder,
          (CourseSourceRow, $$CourseSourceRowsTableReferences),
          CourseSourceRow,
          PrefetchHooks Function({bool termKey})
        > {
  $$CourseSourceRowsTableTableManager(
    _$AppDatabase db,
    $CourseSourceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseSourceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseSourceRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseSourceRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> termKey = const Value.absent(),
                Value<String> termCourseId = const Value.absent(),
                Value<String> offeringId = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<int> packageIndex = const Value.absent(),
                Value<String> sourceStatus = const Value.absent(),
                Value<String> originalFieldsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseSourceRowsCompanion(
                id: id,
                termKey: termKey,
                termCourseId: termCourseId,
                offeringId: offeringId,
                sourceKey: sourceKey,
                packageIndex: packageIndex,
                sourceStatus: sourceStatus,
                originalFieldsJson: originalFieldsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String termKey,
                Value<String> termCourseId = const Value.absent(),
                Value<String> offeringId = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<int> packageIndex = const Value.absent(),
                Value<String> sourceStatus = const Value.absent(),
                Value<String> originalFieldsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseSourceRowsCompanion.insert(
                id: id,
                termKey: termKey,
                termCourseId: termCourseId,
                offeringId: offeringId,
                sourceKey: sourceKey,
                packageIndex: packageIndex,
                sourceStatus: sourceStatus,
                originalFieldsJson: originalFieldsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseSourceRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({termKey = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (termKey) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.termKey,
                                referencedTable:
                                    $$CourseSourceRowsTableReferences
                                        ._termKeyTable(db),
                                referencedColumn:
                                    $$CourseSourceRowsTableReferences
                                        ._termKeyTable(db)
                                        .termKey,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CourseSourceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseSourceRowsTable,
      CourseSourceRow,
      $$CourseSourceRowsTableFilterComposer,
      $$CourseSourceRowsTableOrderingComposer,
      $$CourseSourceRowsTableAnnotationComposer,
      $$CourseSourceRowsTableCreateCompanionBuilder,
      $$CourseSourceRowsTableUpdateCompanionBuilder,
      (CourseSourceRow, $$CourseSourceRowsTableReferences),
      CourseSourceRow,
      PrefetchHooks Function({bool termKey})
    >;
typedef $$CourseMeetingRuleRowsTableCreateCompanionBuilder =
    CourseMeetingRuleRowsCompanion Function({
      required String id,
      required String offeringId,
      required String termKey,
      required String termCourseId,
      required String catalogId,
      required int weekday,
      required int segmentIndex,
      Value<String> weekdayLabel,
      Value<String> rawText,
      Value<String> weekText,
      Value<String> sectionText,
      Value<String> locationText,
      Value<String> building,
      Value<String> room,
      Value<int> rowid,
    });
typedef $$CourseMeetingRuleRowsTableUpdateCompanionBuilder =
    CourseMeetingRuleRowsCompanion Function({
      Value<String> id,
      Value<String> offeringId,
      Value<String> termKey,
      Value<String> termCourseId,
      Value<String> catalogId,
      Value<int> weekday,
      Value<int> segmentIndex,
      Value<String> weekdayLabel,
      Value<String> rawText,
      Value<String> weekText,
      Value<String> sectionText,
      Value<String> locationText,
      Value<String> building,
      Value<String> room,
      Value<int> rowid,
    });

final class $$CourseMeetingRuleRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CourseMeetingRuleRowsTable,
          CourseMeetingRuleRow
        > {
  $$CourseMeetingRuleRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CourseOfferingRowsTable _offeringIdTable(_$AppDatabase db) =>
      db.courseOfferingRows.createAlias(
        $_aliasNameGenerator(
          db.courseMeetingRuleRows.offeringId,
          db.courseOfferingRows.id,
        ),
      );

  $$CourseOfferingRowsTableProcessedTableManager get offeringId {
    final $_column = $_itemColumn<String>('offering_id')!;

    final manager = $$CourseOfferingRowsTableTableManager(
      $_db,
      $_db.courseOfferingRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_offeringIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SchoolTimetableTermRowsTable _termKeyTable(_$AppDatabase db) =>
      db.schoolTimetableTermRows.createAlias(
        $_aliasNameGenerator(
          db.courseMeetingRuleRows.termKey,
          db.schoolTimetableTermRows.termKey,
        ),
      );

  $$SchoolTimetableTermRowsTableProcessedTableManager get termKey {
    final $_column = $_itemColumn<String>('term_key')!;

    final manager = $$SchoolTimetableTermRowsTableTableManager(
      $_db,
      $_db.schoolTimetableTermRows,
    ).filter((f) => f.termKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseTermCourseRowsTable _termCourseIdTable(_$AppDatabase db) =>
      db.courseTermCourseRows.createAlias(
        $_aliasNameGenerator(
          db.courseMeetingRuleRows.termCourseId,
          db.courseTermCourseRows.id,
        ),
      );

  $$CourseTermCourseRowsTableProcessedTableManager get termCourseId {
    final $_column = $_itemColumn<String>('term_course_id')!;

    final manager = $$CourseTermCourseRowsTableTableManager(
      $_db,
      $_db.courseTermCourseRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termCourseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseCatalogRowsTable _catalogIdTable(_$AppDatabase db) =>
      db.courseCatalogRows.createAlias(
        $_aliasNameGenerator(
          db.courseMeetingRuleRows.catalogId,
          db.courseCatalogRows.id,
        ),
      );

  $$CourseCatalogRowsTableProcessedTableManager get catalogId {
    final $_column = $_itemColumn<String>('catalog_id')!;

    final manager = $$CourseCatalogRowsTableTableManager(
      $_db,
      $_db.courseCatalogRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CourseOccurrenceRowsTable,
    List<CourseOccurrenceRow>
  >
  _courseOccurrenceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.courseOccurrenceRows,
        aliasName: $_aliasNameGenerator(
          db.courseMeetingRuleRows.id,
          db.courseOccurrenceRows.ruleId,
        ),
      );

  $$CourseOccurrenceRowsTableProcessedTableManager
  get courseOccurrenceRowsRefs {
    final manager = $$CourseOccurrenceRowsTableTableManager(
      $_db,
      $_db.courseOccurrenceRows,
    ).filter((f) => f.ruleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _courseOccurrenceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CourseMeetingRuleRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseMeetingRuleRowsTable> {
  $$CourseMeetingRuleRowsTableFilterComposer({
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

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekdayLabel => $composableBuilder(
    column: $table.weekdayLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekText => $composableBuilder(
    column: $table.weekText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionText => $composableBuilder(
    column: $table.sectionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get building => $composableBuilder(
    column: $table.building,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  $$CourseOfferingRowsTableFilterComposer get offeringId {
    final $$CourseOfferingRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.offeringId,
      referencedTable: $db.courseOfferingRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOfferingRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOfferingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SchoolTimetableTermRowsTableFilterComposer get termKey {
    final $$SchoolTimetableTermRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableFilterComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseTermCourseRowsTableFilterComposer get termCourseId {
    final $$CourseTermCourseRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termCourseId,
      referencedTable: $db.courseTermCourseRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTermCourseRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseTermCourseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseCatalogRowsTableFilterComposer get catalogId {
    final $$CourseCatalogRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> courseOccurrenceRowsRefs(
    Expression<bool> Function($$CourseOccurrenceRowsTableFilterComposer f) f,
  ) {
    final $$CourseOccurrenceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseOccurrenceRows,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOccurrenceRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOccurrenceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseMeetingRuleRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseMeetingRuleRowsTable> {
  $$CourseMeetingRuleRowsTableOrderingComposer({
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

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdayLabel => $composableBuilder(
    column: $table.weekdayLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekText => $composableBuilder(
    column: $table.weekText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionText => $composableBuilder(
    column: $table.sectionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get building => $composableBuilder(
    column: $table.building,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  $$CourseOfferingRowsTableOrderingComposer get offeringId {
    final $$CourseOfferingRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.offeringId,
      referencedTable: $db.courseOfferingRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOfferingRowsTableOrderingComposer(
            $db: $db,
            $table: $db.courseOfferingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SchoolTimetableTermRowsTableOrderingComposer get termKey {
    final $$SchoolTimetableTermRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableOrderingComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseTermCourseRowsTableOrderingComposer get termCourseId {
    final $$CourseTermCourseRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termCourseId,
          referencedTable: $db.courseTermCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTermCourseRowsTableOrderingComposer(
                $db: $db,
                $table: $db.courseTermCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableOrderingComposer get catalogId {
    final $$CourseCatalogRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableOrderingComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseMeetingRuleRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseMeetingRuleRowsTable> {
  $$CourseMeetingRuleRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get segmentIndex => $composableBuilder(
    column: $table.segmentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekdayLabel => $composableBuilder(
    column: $table.weekdayLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get weekText =>
      $composableBuilder(column: $table.weekText, builder: (column) => column);

  GeneratedColumn<String> get sectionText => $composableBuilder(
    column: $table.sectionText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get building =>
      $composableBuilder(column: $table.building, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  $$CourseOfferingRowsTableAnnotationComposer get offeringId {
    final $$CourseOfferingRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.offeringId,
          referencedTable: $db.courseOfferingRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOfferingRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOfferingRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$SchoolTimetableTermRowsTableAnnotationComposer get termKey {
    final $$SchoolTimetableTermRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseTermCourseRowsTableAnnotationComposer get termCourseId {
    final $$CourseTermCourseRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termCourseId,
          referencedTable: $db.courseTermCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTermCourseRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseTermCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableAnnotationComposer get catalogId {
    final $$CourseCatalogRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogId,
          referencedTable: $db.courseCatalogRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseCatalogRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseCatalogRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> courseOccurrenceRowsRefs<T extends Object>(
    Expression<T> Function($$CourseOccurrenceRowsTableAnnotationComposer a) f,
  ) {
    final $$CourseOccurrenceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.courseOccurrenceRows,
          getReferencedColumn: (t) => t.ruleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOccurrenceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOccurrenceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CourseMeetingRuleRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseMeetingRuleRowsTable,
          CourseMeetingRuleRow,
          $$CourseMeetingRuleRowsTableFilterComposer,
          $$CourseMeetingRuleRowsTableOrderingComposer,
          $$CourseMeetingRuleRowsTableAnnotationComposer,
          $$CourseMeetingRuleRowsTableCreateCompanionBuilder,
          $$CourseMeetingRuleRowsTableUpdateCompanionBuilder,
          (CourseMeetingRuleRow, $$CourseMeetingRuleRowsTableReferences),
          CourseMeetingRuleRow,
          PrefetchHooks Function({
            bool offeringId,
            bool termKey,
            bool termCourseId,
            bool catalogId,
            bool courseOccurrenceRowsRefs,
          })
        > {
  $$CourseMeetingRuleRowsTableTableManager(
    _$AppDatabase db,
    $CourseMeetingRuleRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseMeetingRuleRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CourseMeetingRuleRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CourseMeetingRuleRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> offeringId = const Value.absent(),
                Value<String> termKey = const Value.absent(),
                Value<String> termCourseId = const Value.absent(),
                Value<String> catalogId = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> segmentIndex = const Value.absent(),
                Value<String> weekdayLabel = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<String> weekText = const Value.absent(),
                Value<String> sectionText = const Value.absent(),
                Value<String> locationText = const Value.absent(),
                Value<String> building = const Value.absent(),
                Value<String> room = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseMeetingRuleRowsCompanion(
                id: id,
                offeringId: offeringId,
                termKey: termKey,
                termCourseId: termCourseId,
                catalogId: catalogId,
                weekday: weekday,
                segmentIndex: segmentIndex,
                weekdayLabel: weekdayLabel,
                rawText: rawText,
                weekText: weekText,
                sectionText: sectionText,
                locationText: locationText,
                building: building,
                room: room,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String offeringId,
                required String termKey,
                required String termCourseId,
                required String catalogId,
                required int weekday,
                required int segmentIndex,
                Value<String> weekdayLabel = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<String> weekText = const Value.absent(),
                Value<String> sectionText = const Value.absent(),
                Value<String> locationText = const Value.absent(),
                Value<String> building = const Value.absent(),
                Value<String> room = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseMeetingRuleRowsCompanion.insert(
                id: id,
                offeringId: offeringId,
                termKey: termKey,
                termCourseId: termCourseId,
                catalogId: catalogId,
                weekday: weekday,
                segmentIndex: segmentIndex,
                weekdayLabel: weekdayLabel,
                rawText: rawText,
                weekText: weekText,
                sectionText: sectionText,
                locationText: locationText,
                building: building,
                room: room,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseMeetingRuleRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                offeringId = false,
                termKey = false,
                termCourseId = false,
                catalogId = false,
                courseOccurrenceRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (courseOccurrenceRowsRefs) db.courseOccurrenceRows,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (offeringId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.offeringId,
                                    referencedTable:
                                        $$CourseMeetingRuleRowsTableReferences
                                            ._offeringIdTable(db),
                                    referencedColumn:
                                        $$CourseMeetingRuleRowsTableReferences
                                            ._offeringIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (termKey) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termKey,
                                    referencedTable:
                                        $$CourseMeetingRuleRowsTableReferences
                                            ._termKeyTable(db),
                                    referencedColumn:
                                        $$CourseMeetingRuleRowsTableReferences
                                            ._termKeyTable(db)
                                            .termKey,
                                  )
                                  as T;
                        }
                        if (termCourseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termCourseId,
                                    referencedTable:
                                        $$CourseMeetingRuleRowsTableReferences
                                            ._termCourseIdTable(db),
                                    referencedColumn:
                                        $$CourseMeetingRuleRowsTableReferences
                                            ._termCourseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (catalogId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.catalogId,
                                    referencedTable:
                                        $$CourseMeetingRuleRowsTableReferences
                                            ._catalogIdTable(db),
                                    referencedColumn:
                                        $$CourseMeetingRuleRowsTableReferences
                                            ._catalogIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (courseOccurrenceRowsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable:
                              $$CourseMeetingRuleRowsTableReferences
                                  ._courseOccurrenceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseMeetingRuleRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseOccurrenceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ruleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CourseMeetingRuleRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseMeetingRuleRowsTable,
      CourseMeetingRuleRow,
      $$CourseMeetingRuleRowsTableFilterComposer,
      $$CourseMeetingRuleRowsTableOrderingComposer,
      $$CourseMeetingRuleRowsTableAnnotationComposer,
      $$CourseMeetingRuleRowsTableCreateCompanionBuilder,
      $$CourseMeetingRuleRowsTableUpdateCompanionBuilder,
      (CourseMeetingRuleRow, $$CourseMeetingRuleRowsTableReferences),
      CourseMeetingRuleRow,
      PrefetchHooks Function({
        bool offeringId,
        bool termKey,
        bool termCourseId,
        bool catalogId,
        bool courseOccurrenceRowsRefs,
      })
    >;
typedef $$CourseOccurrenceRowsTableCreateCompanionBuilder =
    CourseOccurrenceRowsCompanion Function({
      required String id,
      required String ruleId,
      required String offeringId,
      required String termKey,
      required String termCourseId,
      required String catalogId,
      required String date,
      required int weekIndex,
      required int weekday,
      Value<String> sectionText,
      Value<String> locationText,
      Value<String> building,
      Value<String> room,
      Value<int> rowid,
    });
typedef $$CourseOccurrenceRowsTableUpdateCompanionBuilder =
    CourseOccurrenceRowsCompanion Function({
      Value<String> id,
      Value<String> ruleId,
      Value<String> offeringId,
      Value<String> termKey,
      Value<String> termCourseId,
      Value<String> catalogId,
      Value<String> date,
      Value<int> weekIndex,
      Value<int> weekday,
      Value<String> sectionText,
      Value<String> locationText,
      Value<String> building,
      Value<String> room,
      Value<int> rowid,
    });

final class $$CourseOccurrenceRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CourseOccurrenceRowsTable,
          CourseOccurrenceRow
        > {
  $$CourseOccurrenceRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CourseMeetingRuleRowsTable _ruleIdTable(_$AppDatabase db) =>
      db.courseMeetingRuleRows.createAlias(
        $_aliasNameGenerator(
          db.courseOccurrenceRows.ruleId,
          db.courseMeetingRuleRows.id,
        ),
      );

  $$CourseMeetingRuleRowsTableProcessedTableManager get ruleId {
    final $_column = $_itemColumn<String>('rule_id')!;

    final manager = $$CourseMeetingRuleRowsTableTableManager(
      $_db,
      $_db.courseMeetingRuleRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseOfferingRowsTable _offeringIdTable(_$AppDatabase db) =>
      db.courseOfferingRows.createAlias(
        $_aliasNameGenerator(
          db.courseOccurrenceRows.offeringId,
          db.courseOfferingRows.id,
        ),
      );

  $$CourseOfferingRowsTableProcessedTableManager get offeringId {
    final $_column = $_itemColumn<String>('offering_id')!;

    final manager = $$CourseOfferingRowsTableTableManager(
      $_db,
      $_db.courseOfferingRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_offeringIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SchoolTimetableTermRowsTable _termKeyTable(_$AppDatabase db) =>
      db.schoolTimetableTermRows.createAlias(
        $_aliasNameGenerator(
          db.courseOccurrenceRows.termKey,
          db.schoolTimetableTermRows.termKey,
        ),
      );

  $$SchoolTimetableTermRowsTableProcessedTableManager get termKey {
    final $_column = $_itemColumn<String>('term_key')!;

    final manager = $$SchoolTimetableTermRowsTableTableManager(
      $_db,
      $_db.schoolTimetableTermRows,
    ).filter((f) => f.termKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseTermCourseRowsTable _termCourseIdTable(_$AppDatabase db) =>
      db.courseTermCourseRows.createAlias(
        $_aliasNameGenerator(
          db.courseOccurrenceRows.termCourseId,
          db.courseTermCourseRows.id,
        ),
      );

  $$CourseTermCourseRowsTableProcessedTableManager get termCourseId {
    final $_column = $_itemColumn<String>('term_course_id')!;

    final manager = $$CourseTermCourseRowsTableTableManager(
      $_db,
      $_db.courseTermCourseRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termCourseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CourseCatalogRowsTable _catalogIdTable(_$AppDatabase db) =>
      db.courseCatalogRows.createAlias(
        $_aliasNameGenerator(
          db.courseOccurrenceRows.catalogId,
          db.courseCatalogRows.id,
        ),
      );

  $$CourseCatalogRowsTableProcessedTableManager get catalogId {
    final $_column = $_itemColumn<String>('catalog_id')!;

    final manager = $$CourseCatalogRowsTableTableManager(
      $_db,
      $_db.courseCatalogRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CourseOccurrenceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseOccurrenceRowsTable> {
  $$CourseOccurrenceRowsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekIndex => $composableBuilder(
    column: $table.weekIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionText => $composableBuilder(
    column: $table.sectionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get building => $composableBuilder(
    column: $table.building,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  $$CourseMeetingRuleRowsTableFilterComposer get ruleId {
    final $$CourseMeetingRuleRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.ruleId,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableFilterComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseOfferingRowsTableFilterComposer get offeringId {
    final $$CourseOfferingRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.offeringId,
      referencedTable: $db.courseOfferingRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOfferingRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseOfferingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SchoolTimetableTermRowsTableFilterComposer get termKey {
    final $$SchoolTimetableTermRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableFilterComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseTermCourseRowsTableFilterComposer get termCourseId {
    final $$CourseTermCourseRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termCourseId,
      referencedTable: $db.courseTermCourseRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTermCourseRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseTermCourseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CourseCatalogRowsTableFilterComposer get catalogId {
    final $$CourseCatalogRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableFilterComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseOccurrenceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseOccurrenceRowsTable> {
  $$CourseOccurrenceRowsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekIndex => $composableBuilder(
    column: $table.weekIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionText => $composableBuilder(
    column: $table.sectionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get building => $composableBuilder(
    column: $table.building,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  $$CourseMeetingRuleRowsTableOrderingComposer get ruleId {
    final $$CourseMeetingRuleRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.ruleId,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableOrderingComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseOfferingRowsTableOrderingComposer get offeringId {
    final $$CourseOfferingRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.offeringId,
      referencedTable: $db.courseOfferingRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseOfferingRowsTableOrderingComposer(
            $db: $db,
            $table: $db.courseOfferingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SchoolTimetableTermRowsTableOrderingComposer get termKey {
    final $$SchoolTimetableTermRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableOrderingComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseTermCourseRowsTableOrderingComposer get termCourseId {
    final $$CourseTermCourseRowsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termCourseId,
          referencedTable: $db.courseTermCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTermCourseRowsTableOrderingComposer(
                $db: $db,
                $table: $db.courseTermCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableOrderingComposer get catalogId {
    final $$CourseCatalogRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogId,
      referencedTable: $db.courseCatalogRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseCatalogRowsTableOrderingComposer(
            $db: $db,
            $table: $db.courseCatalogRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseOccurrenceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseOccurrenceRowsTable> {
  $$CourseOccurrenceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get weekIndex =>
      $composableBuilder(column: $table.weekIndex, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get sectionText => $composableBuilder(
    column: $table.sectionText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get building =>
      $composableBuilder(column: $table.building, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  $$CourseMeetingRuleRowsTableAnnotationComposer get ruleId {
    final $$CourseMeetingRuleRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.ruleId,
          referencedTable: $db.courseMeetingRuleRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseMeetingRuleRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseMeetingRuleRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseOfferingRowsTableAnnotationComposer get offeringId {
    final $$CourseOfferingRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.offeringId,
          referencedTable: $db.courseOfferingRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseOfferingRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseOfferingRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$SchoolTimetableTermRowsTableAnnotationComposer get termKey {
    final $$SchoolTimetableTermRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termKey,
          referencedTable: $db.schoolTimetableTermRows,
          getReferencedColumn: (t) => t.termKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SchoolTimetableTermRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.schoolTimetableTermRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseTermCourseRowsTableAnnotationComposer get termCourseId {
    final $$CourseTermCourseRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.termCourseId,
          referencedTable: $db.courseTermCourseRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseTermCourseRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseTermCourseRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CourseCatalogRowsTableAnnotationComposer get catalogId {
    final $$CourseCatalogRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogId,
          referencedTable: $db.courseCatalogRows,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CourseCatalogRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.courseCatalogRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CourseOccurrenceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseOccurrenceRowsTable,
          CourseOccurrenceRow,
          $$CourseOccurrenceRowsTableFilterComposer,
          $$CourseOccurrenceRowsTableOrderingComposer,
          $$CourseOccurrenceRowsTableAnnotationComposer,
          $$CourseOccurrenceRowsTableCreateCompanionBuilder,
          $$CourseOccurrenceRowsTableUpdateCompanionBuilder,
          (CourseOccurrenceRow, $$CourseOccurrenceRowsTableReferences),
          CourseOccurrenceRow,
          PrefetchHooks Function({
            bool ruleId,
            bool offeringId,
            bool termKey,
            bool termCourseId,
            bool catalogId,
          })
        > {
  $$CourseOccurrenceRowsTableTableManager(
    _$AppDatabase db,
    $CourseOccurrenceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseOccurrenceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseOccurrenceRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CourseOccurrenceRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<String> offeringId = const Value.absent(),
                Value<String> termKey = const Value.absent(),
                Value<String> termCourseId = const Value.absent(),
                Value<String> catalogId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> weekIndex = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<String> sectionText = const Value.absent(),
                Value<String> locationText = const Value.absent(),
                Value<String> building = const Value.absent(),
                Value<String> room = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseOccurrenceRowsCompanion(
                id: id,
                ruleId: ruleId,
                offeringId: offeringId,
                termKey: termKey,
                termCourseId: termCourseId,
                catalogId: catalogId,
                date: date,
                weekIndex: weekIndex,
                weekday: weekday,
                sectionText: sectionText,
                locationText: locationText,
                building: building,
                room: room,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ruleId,
                required String offeringId,
                required String termKey,
                required String termCourseId,
                required String catalogId,
                required String date,
                required int weekIndex,
                required int weekday,
                Value<String> sectionText = const Value.absent(),
                Value<String> locationText = const Value.absent(),
                Value<String> building = const Value.absent(),
                Value<String> room = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseOccurrenceRowsCompanion.insert(
                id: id,
                ruleId: ruleId,
                offeringId: offeringId,
                termKey: termKey,
                termCourseId: termCourseId,
                catalogId: catalogId,
                date: date,
                weekIndex: weekIndex,
                weekday: weekday,
                sectionText: sectionText,
                locationText: locationText,
                building: building,
                room: room,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseOccurrenceRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ruleId = false,
                offeringId = false,
                termKey = false,
                termCourseId = false,
                catalogId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (ruleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ruleId,
                                    referencedTable:
                                        $$CourseOccurrenceRowsTableReferences
                                            ._ruleIdTable(db),
                                    referencedColumn:
                                        $$CourseOccurrenceRowsTableReferences
                                            ._ruleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (offeringId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.offeringId,
                                    referencedTable:
                                        $$CourseOccurrenceRowsTableReferences
                                            ._offeringIdTable(db),
                                    referencedColumn:
                                        $$CourseOccurrenceRowsTableReferences
                                            ._offeringIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (termKey) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termKey,
                                    referencedTable:
                                        $$CourseOccurrenceRowsTableReferences
                                            ._termKeyTable(db),
                                    referencedColumn:
                                        $$CourseOccurrenceRowsTableReferences
                                            ._termKeyTable(db)
                                            .termKey,
                                  )
                                  as T;
                        }
                        if (termCourseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termCourseId,
                                    referencedTable:
                                        $$CourseOccurrenceRowsTableReferences
                                            ._termCourseIdTable(db),
                                    referencedColumn:
                                        $$CourseOccurrenceRowsTableReferences
                                            ._termCourseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (catalogId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.catalogId,
                                    referencedTable:
                                        $$CourseOccurrenceRowsTableReferences
                                            ._catalogIdTable(db),
                                    referencedColumn:
                                        $$CourseOccurrenceRowsTableReferences
                                            ._catalogIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$CourseOccurrenceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseOccurrenceRowsTable,
      CourseOccurrenceRow,
      $$CourseOccurrenceRowsTableFilterComposer,
      $$CourseOccurrenceRowsTableOrderingComposer,
      $$CourseOccurrenceRowsTableAnnotationComposer,
      $$CourseOccurrenceRowsTableCreateCompanionBuilder,
      $$CourseOccurrenceRowsTableUpdateCompanionBuilder,
      (CourseOccurrenceRow, $$CourseOccurrenceRowsTableReferences),
      CourseOccurrenceRow,
      PrefetchHooks Function({
        bool ruleId,
        bool offeringId,
        bool termKey,
        bool termCourseId,
        bool catalogId,
      })
    >;
typedef $$SyncTombstoneRowsTableCreateCompanionBuilder =
    SyncTombstoneRowsCompanion Function({
      required String entityType,
      required String entityId,
      Value<int> revision,
      Value<bool> dirty,
      required DateTime deletedAt,
      Value<int> rowid,
    });
typedef $$SyncTombstoneRowsTableUpdateCompanionBuilder =
    SyncTombstoneRowsCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<int> revision,
      Value<bool> dirty,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });

class $$SyncTombstoneRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncTombstoneRowsTable> {
  $$SyncTombstoneRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncTombstoneRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncTombstoneRowsTable> {
  $$SyncTombstoneRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncTombstoneRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncTombstoneRowsTable> {
  $$SyncTombstoneRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$SyncTombstoneRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncTombstoneRowsTable,
          SyncTombstoneRow,
          $$SyncTombstoneRowsTableFilterComposer,
          $$SyncTombstoneRowsTableOrderingComposer,
          $$SyncTombstoneRowsTableAnnotationComposer,
          $$SyncTombstoneRowsTableCreateCompanionBuilder,
          $$SyncTombstoneRowsTableUpdateCompanionBuilder,
          (
            SyncTombstoneRow,
            BaseReferences<
              _$AppDatabase,
              $SyncTombstoneRowsTable,
              SyncTombstoneRow
            >,
          ),
          SyncTombstoneRow,
          PrefetchHooks Function()
        > {
  $$SyncTombstoneRowsTableTableManager(
    _$AppDatabase db,
    $SyncTombstoneRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncTombstoneRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncTombstoneRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncTombstoneRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncTombstoneRowsCompanion(
                entityType: entityType,
                entityId: entityId,
                revision: revision,
                dirty: dirty,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                Value<int> revision = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required DateTime deletedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncTombstoneRowsCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                revision: revision,
                dirty: dirty,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncTombstoneRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncTombstoneRowsTable,
      SyncTombstoneRow,
      $$SyncTombstoneRowsTableFilterComposer,
      $$SyncTombstoneRowsTableOrderingComposer,
      $$SyncTombstoneRowsTableAnnotationComposer,
      $$SyncTombstoneRowsTableCreateCompanionBuilder,
      $$SyncTombstoneRowsTableUpdateCompanionBuilder,
      (
        SyncTombstoneRow,
        BaseReferences<
          _$AppDatabase,
          $SyncTombstoneRowsTable,
          SyncTombstoneRow
        >,
      ),
      SyncTombstoneRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AgendaItemRowsTableTableManager get agendaItemRows =>
      $$AgendaItemRowsTableTableManager(_db, _db.agendaItemRows);
  $$ScheduleItemDetailRowsTableTableManager get scheduleItemDetailRows =>
      $$ScheduleItemDetailRowsTableTableManager(
        _db,
        _db.scheduleItemDetailRows,
      );
  $$TaskItemDetailRowsTableTableManager get taskItemDetailRows =>
      $$TaskItemDetailRowsTableTableManager(_db, _db.taskItemDetailRows);
  $$CourseItemDetailRowsTableTableManager get courseItemDetailRows =>
      $$CourseItemDetailRowsTableTableManager(_db, _db.courseItemDetailRows);
  $$CourseTimetableRowsTableTableManager get courseTimetableRows =>
      $$CourseTimetableRowsTableTableManager(_db, _db.courseTimetableRows);
  $$SelectedCourseTimetableRowsTableTableManager
  get selectedCourseTimetableRows =>
      $$SelectedCourseTimetableRowsTableTableManager(
        _db,
        _db.selectedCourseTimetableRows,
      );
  $$SchoolTimetableTermRowsTableTableManager get schoolTimetableTermRows =>
      $$SchoolTimetableTermRowsTableTableManager(
        _db,
        _db.schoolTimetableTermRows,
      );
  $$CourseCatalogRowsTableTableManager get courseCatalogRows =>
      $$CourseCatalogRowsTableTableManager(_db, _db.courseCatalogRows);
  $$CourseTermCourseRowsTableTableManager get courseTermCourseRows =>
      $$CourseTermCourseRowsTableTableManager(_db, _db.courseTermCourseRows);
  $$CourseInstructorCourseRowsTableTableManager
  get courseInstructorCourseRows =>
      $$CourseInstructorCourseRowsTableTableManager(
        _db,
        _db.courseInstructorCourseRows,
      );
  $$CourseOfferingRowsTableTableManager get courseOfferingRows =>
      $$CourseOfferingRowsTableTableManager(_db, _db.courseOfferingRows);
  $$CourseAudienceRowsTableTableManager get courseAudienceRows =>
      $$CourseAudienceRowsTableTableManager(_db, _db.courseAudienceRows);
  $$CourseSourceRowsTableTableManager get courseSourceRows =>
      $$CourseSourceRowsTableTableManager(_db, _db.courseSourceRows);
  $$CourseMeetingRuleRowsTableTableManager get courseMeetingRuleRows =>
      $$CourseMeetingRuleRowsTableTableManager(_db, _db.courseMeetingRuleRows);
  $$CourseOccurrenceRowsTableTableManager get courseOccurrenceRows =>
      $$CourseOccurrenceRowsTableTableManager(_db, _db.courseOccurrenceRows);
  $$SyncTombstoneRowsTableTableManager get syncTombstoneRows =>
      $$SyncTombstoneRowsTableTableManager(_db, _db.syncTombstoneRows);
}
