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
  $$SyncTombstoneRowsTableTableManager get syncTombstoneRows =>
      $$SyncTombstoneRowsTableTableManager(_db, _db.syncTombstoneRows);
}
