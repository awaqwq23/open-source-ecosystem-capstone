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
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedDurationMinutesMeta =
      const VerificationMeta('estimatedDurationMinutes');
  @override
  late final GeneratedColumn<int> estimatedDurationMinutes =
      GeneratedColumn<int>(
        'estimated_duration_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
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
  static const VerificationMeta _courseTimetableIdMeta = const VerificationMeta(
    'courseTimetableId',
  );
  @override
  late final GeneratedColumn<String> courseTimetableId =
      GeneratedColumn<String>(
        'course_timetable_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _courseSourceKindMeta = const VerificationMeta(
    'courseSourceKind',
  );
  @override
  late final GeneratedColumn<String> courseSourceKind = GeneratedColumn<String>(
    'course_source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _courseSourceCourseIdMeta =
      const VerificationMeta('courseSourceCourseId');
  @override
  late final GeneratedColumn<String> courseSourceCourseId =
      GeneratedColumn<String>(
        'course_source_course_id',
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
    startAt,
    endAt,
    isAllDay,
    deadline,
    estimatedDurationMinutes,
    isCompleted,
    completedAt,
    sortOrder,
    sourceKind,
    sourceRef,
    courseTimetableId,
    courseSourceKind,
    courseSourceCourseId,
    courseNature,
    instructor,
    weekMeta,
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
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('estimated_duration_minutes')) {
      context.handle(
        _estimatedDurationMinutesMeta,
        estimatedDurationMinutes.isAcceptableOrUnknown(
          data['estimated_duration_minutes']!,
          _estimatedDurationMinutesMeta,
        ),
      );
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
    if (data.containsKey('course_timetable_id')) {
      context.handle(
        _courseTimetableIdMeta,
        courseTimetableId.isAcceptableOrUnknown(
          data['course_timetable_id']!,
          _courseTimetableIdMeta,
        ),
      );
    }
    if (data.containsKey('course_source_kind')) {
      context.handle(
        _courseSourceKindMeta,
        courseSourceKind.isAcceptableOrUnknown(
          data['course_source_kind']!,
          _courseSourceKindMeta,
        ),
      );
    }
    if (data.containsKey('course_source_course_id')) {
      context.handle(
        _courseSourceCourseIdMeta,
        courseSourceCourseId.isAcceptableOrUnknown(
          data['course_source_course_id']!,
          _courseSourceCourseIdMeta,
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
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      estimatedDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_duration_minutes'],
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
      courseTimetableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_timetable_id'],
      )!,
      courseSourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_source_kind'],
      )!,
      courseSourceCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_source_course_id'],
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
  final DateTime startAt;
  final DateTime endAt;
  final bool isAllDay;
  final DateTime? deadline;
  final int estimatedDurationMinutes;
  final bool isCompleted;
  final DateTime? completedAt;
  final double sortOrder;
  final String sourceKind;
  final String sourceRef;
  final String courseTimetableId;
  final String courseSourceKind;
  final String courseSourceCourseId;
  final String courseNature;
  final String instructor;
  final String weekMeta;
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
    required this.startAt,
    required this.endAt,
    required this.isAllDay,
    this.deadline,
    required this.estimatedDurationMinutes,
    required this.isCompleted,
    this.completedAt,
    required this.sortOrder,
    required this.sourceKind,
    required this.sourceRef,
    required this.courseTimetableId,
    required this.courseSourceKind,
    required this.courseSourceCourseId,
    required this.courseNature,
    required this.instructor,
    required this.weekMeta,
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
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    map['is_all_day'] = Variable<bool>(isAllDay);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    map['estimated_duration_minutes'] = Variable<int>(estimatedDurationMinutes);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['sort_order'] = Variable<double>(sortOrder);
    map['source_kind'] = Variable<String>(sourceKind);
    map['source_ref'] = Variable<String>(sourceRef);
    map['course_timetable_id'] = Variable<String>(courseTimetableId);
    map['course_source_kind'] = Variable<String>(courseSourceKind);
    map['course_source_course_id'] = Variable<String>(courseSourceCourseId);
    map['course_nature'] = Variable<String>(courseNature);
    map['instructor'] = Variable<String>(instructor);
    map['week_meta'] = Variable<String>(weekMeta);
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
      startAt: Value(startAt),
      endAt: Value(endAt),
      isAllDay: Value(isAllDay),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      estimatedDurationMinutes: Value(estimatedDurationMinutes),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      sortOrder: Value(sortOrder),
      sourceKind: Value(sourceKind),
      sourceRef: Value(sourceRef),
      courseTimetableId: Value(courseTimetableId),
      courseSourceKind: Value(courseSourceKind),
      courseSourceCourseId: Value(courseSourceCourseId),
      courseNature: Value(courseNature),
      instructor: Value(instructor),
      weekMeta: Value(weekMeta),
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
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      estimatedDurationMinutes: serializer.fromJson<int>(
        json['estimatedDurationMinutes'],
      ),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
      sourceRef: serializer.fromJson<String>(json['sourceRef']),
      courseTimetableId: serializer.fromJson<String>(json['courseTimetableId']),
      courseSourceKind: serializer.fromJson<String>(json['courseSourceKind']),
      courseSourceCourseId: serializer.fromJson<String>(
        json['courseSourceCourseId'],
      ),
      courseNature: serializer.fromJson<String>(json['courseNature']),
      instructor: serializer.fromJson<String>(json['instructor']),
      weekMeta: serializer.fromJson<String>(json['weekMeta']),
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
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'estimatedDurationMinutes': serializer.toJson<int>(
        estimatedDurationMinutes,
      ),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'sortOrder': serializer.toJson<double>(sortOrder),
      'sourceKind': serializer.toJson<String>(sourceKind),
      'sourceRef': serializer.toJson<String>(sourceRef),
      'courseTimetableId': serializer.toJson<String>(courseTimetableId),
      'courseSourceKind': serializer.toJson<String>(courseSourceKind),
      'courseSourceCourseId': serializer.toJson<String>(courseSourceCourseId),
      'courseNature': serializer.toJson<String>(courseNature),
      'instructor': serializer.toJson<String>(instructor),
      'weekMeta': serializer.toJson<String>(weekMeta),
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
    DateTime? startAt,
    DateTime? endAt,
    bool? isAllDay,
    Value<DateTime?> deadline = const Value.absent(),
    int? estimatedDurationMinutes,
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    double? sortOrder,
    String? sourceKind,
    String? sourceRef,
    String? courseTimetableId,
    String? courseSourceKind,
    String? courseSourceCourseId,
    String? courseNature,
    String? instructor,
    String? weekMeta,
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
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    isAllDay: isAllDay ?? this.isAllDay,
    deadline: deadline.present ? deadline.value : this.deadline,
    estimatedDurationMinutes:
        estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    sortOrder: sortOrder ?? this.sortOrder,
    sourceKind: sourceKind ?? this.sourceKind,
    sourceRef: sourceRef ?? this.sourceRef,
    courseTimetableId: courseTimetableId ?? this.courseTimetableId,
    courseSourceKind: courseSourceKind ?? this.courseSourceKind,
    courseSourceCourseId: courseSourceCourseId ?? this.courseSourceCourseId,
    courseNature: courseNature ?? this.courseNature,
    instructor: instructor ?? this.instructor,
    weekMeta: weekMeta ?? this.weekMeta,
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
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      estimatedDurationMinutes: data.estimatedDurationMinutes.present
          ? data.estimatedDurationMinutes.value
          : this.estimatedDurationMinutes,
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
      courseTimetableId: data.courseTimetableId.present
          ? data.courseTimetableId.value
          : this.courseTimetableId,
      courseSourceKind: data.courseSourceKind.present
          ? data.courseSourceKind.value
          : this.courseSourceKind,
      courseSourceCourseId: data.courseSourceCourseId.present
          ? data.courseSourceCourseId.value
          : this.courseSourceCourseId,
      courseNature: data.courseNature.present
          ? data.courseNature.value
          : this.courseNature,
      instructor: data.instructor.present
          ? data.instructor.value
          : this.instructor,
      weekMeta: data.weekMeta.present ? data.weekMeta.value : this.weekMeta,
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
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('deadline: $deadline, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('courseTimetableId: $courseTimetableId, ')
          ..write('courseSourceKind: $courseSourceKind, ')
          ..write('courseSourceCourseId: $courseSourceCourseId, ')
          ..write('courseNature: $courseNature, ')
          ..write('instructor: $instructor, ')
          ..write('weekMeta: $weekMeta, ')
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
  int get hashCode => Object.hashAll([
    id,
    type,
    title,
    notes,
    location,
    color,
    reminder,
    repeatRule,
    startAt,
    endAt,
    isAllDay,
    deadline,
    estimatedDurationMinutes,
    isCompleted,
    completedAt,
    sortOrder,
    sourceKind,
    sourceRef,
    courseTimetableId,
    courseSourceKind,
    courseSourceCourseId,
    courseNature,
    instructor,
    weekMeta,
    remoteId,
    revision,
    dirty,
    deletedAt,
    lastSyncedAt,
    createdAt,
    updatedAt,
  ]);
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
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.isAllDay == this.isAllDay &&
          other.deadline == this.deadline &&
          other.estimatedDurationMinutes == this.estimatedDurationMinutes &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.sortOrder == this.sortOrder &&
          other.sourceKind == this.sourceKind &&
          other.sourceRef == this.sourceRef &&
          other.courseTimetableId == this.courseTimetableId &&
          other.courseSourceKind == this.courseSourceKind &&
          other.courseSourceCourseId == this.courseSourceCourseId &&
          other.courseNature == this.courseNature &&
          other.instructor == this.instructor &&
          other.weekMeta == this.weekMeta &&
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
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<bool> isAllDay;
  final Value<DateTime?> deadline;
  final Value<int> estimatedDurationMinutes;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<double> sortOrder;
  final Value<String> sourceKind;
  final Value<String> sourceRef;
  final Value<String> courseTimetableId;
  final Value<String> courseSourceKind;
  final Value<String> courseSourceCourseId;
  final Value<String> courseNature;
  final Value<String> instructor;
  final Value<String> weekMeta;
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
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.deadline = const Value.absent(),
    this.estimatedDurationMinutes = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.courseTimetableId = const Value.absent(),
    this.courseSourceKind = const Value.absent(),
    this.courseSourceCourseId = const Value.absent(),
    this.courseNature = const Value.absent(),
    this.instructor = const Value.absent(),
    this.weekMeta = const Value.absent(),
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
    required DateTime startAt,
    required DateTime endAt,
    this.isAllDay = const Value.absent(),
    this.deadline = const Value.absent(),
    this.estimatedDurationMinutes = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.courseTimetableId = const Value.absent(),
    this.courseSourceKind = const Value.absent(),
    this.courseSourceCourseId = const Value.absent(),
    this.courseNature = const Value.absent(),
    this.instructor = const Value.absent(),
    this.weekMeta = const Value.absent(),
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
       startAt = Value(startAt),
       endAt = Value(endAt),
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
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<bool>? isAllDay,
    Expression<DateTime>? deadline,
    Expression<int>? estimatedDurationMinutes,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<double>? sortOrder,
    Expression<String>? sourceKind,
    Expression<String>? sourceRef,
    Expression<String>? courseTimetableId,
    Expression<String>? courseSourceKind,
    Expression<String>? courseSourceCourseId,
    Expression<String>? courseNature,
    Expression<String>? instructor,
    Expression<String>? weekMeta,
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
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (deadline != null) 'deadline': deadline,
      if (estimatedDurationMinutes != null)
        'estimated_duration_minutes': estimatedDurationMinutes,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (courseTimetableId != null) 'course_timetable_id': courseTimetableId,
      if (courseSourceKind != null) 'course_source_kind': courseSourceKind,
      if (courseSourceCourseId != null)
        'course_source_course_id': courseSourceCourseId,
      if (courseNature != null) 'course_nature': courseNature,
      if (instructor != null) 'instructor': instructor,
      if (weekMeta != null) 'week_meta': weekMeta,
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
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<bool>? isAllDay,
    Value<DateTime?>? deadline,
    Value<int>? estimatedDurationMinutes,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<double>? sortOrder,
    Value<String>? sourceKind,
    Value<String>? sourceRef,
    Value<String>? courseTimetableId,
    Value<String>? courseSourceKind,
    Value<String>? courseSourceCourseId,
    Value<String>? courseNature,
    Value<String>? instructor,
    Value<String>? weekMeta,
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
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isAllDay: isAllDay ?? this.isAllDay,
      deadline: deadline ?? this.deadline,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceRef: sourceRef ?? this.sourceRef,
      courseTimetableId: courseTimetableId ?? this.courseTimetableId,
      courseSourceKind: courseSourceKind ?? this.courseSourceKind,
      courseSourceCourseId: courseSourceCourseId ?? this.courseSourceCourseId,
      courseNature: courseNature ?? this.courseNature,
      instructor: instructor ?? this.instructor,
      weekMeta: weekMeta ?? this.weekMeta,
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
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (estimatedDurationMinutes.present) {
      map['estimated_duration_minutes'] = Variable<int>(
        estimatedDurationMinutes.value,
      );
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
    if (courseTimetableId.present) {
      map['course_timetable_id'] = Variable<String>(courseTimetableId.value);
    }
    if (courseSourceKind.present) {
      map['course_source_kind'] = Variable<String>(courseSourceKind.value);
    }
    if (courseSourceCourseId.present) {
      map['course_source_course_id'] = Variable<String>(
        courseSourceCourseId.value,
      );
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
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('deadline: $deadline, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('courseTimetableId: $courseTimetableId, ')
          ..write('courseSourceKind: $courseSourceKind, ')
          ..write('courseSourceCourseId: $courseSourceCourseId, ')
          ..write('courseNature: $courseNature, ')
          ..write('instructor: $instructor, ')
          ..write('weekMeta: $weekMeta, ')
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
      required DateTime startAt,
      required DateTime endAt,
      Value<bool> isAllDay,
      Value<DateTime?> deadline,
      Value<int> estimatedDurationMinutes,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<double> sortOrder,
      Value<String> sourceKind,
      Value<String> sourceRef,
      Value<String> courseTimetableId,
      Value<String> courseSourceKind,
      Value<String> courseSourceCourseId,
      Value<String> courseNature,
      Value<String> instructor,
      Value<String> weekMeta,
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
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<bool> isAllDay,
      Value<DateTime?> deadline,
      Value<int> estimatedDurationMinutes,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<double> sortOrder,
      Value<String> sourceKind,
      Value<String> sourceRef,
      Value<String> courseTimetableId,
      Value<String> courseSourceKind,
      Value<String> courseSourceCourseId,
      Value<String> courseNature,
      Value<String> instructor,
      Value<String> weekMeta,
      Value<String?> remoteId,
      Value<int> revision,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

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

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
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

  ColumnFilters<String> get courseTimetableId => $composableBuilder(
    column: $table.courseTimetableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseSourceKind => $composableBuilder(
    column: $table.courseSourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseSourceCourseId => $composableBuilder(
    column: $table.courseSourceCourseId,
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

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
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

  ColumnOrderings<String> get courseTimetableId => $composableBuilder(
    column: $table.courseTimetableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseSourceKind => $composableBuilder(
    column: $table.courseSourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseSourceCourseId => $composableBuilder(
    column: $table.courseSourceCourseId,
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

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
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

  GeneratedColumn<String> get courseTimetableId => $composableBuilder(
    column: $table.courseTimetableId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseSourceKind => $composableBuilder(
    column: $table.courseSourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseSourceCourseId => $composableBuilder(
    column: $table.courseSourceCourseId,
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
          (
            AgendaItemRow,
            BaseReferences<_$AppDatabase, $AgendaItemRowsTable, AgendaItemRow>,
          ),
          AgendaItemRow,
          PrefetchHooks Function()
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
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<int> estimatedDurationMinutes = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String> sourceRef = const Value.absent(),
                Value<String> courseTimetableId = const Value.absent(),
                Value<String> courseSourceKind = const Value.absent(),
                Value<String> courseSourceCourseId = const Value.absent(),
                Value<String> courseNature = const Value.absent(),
                Value<String> instructor = const Value.absent(),
                Value<String> weekMeta = const Value.absent(),
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
                startAt: startAt,
                endAt: endAt,
                isAllDay: isAllDay,
                deadline: deadline,
                estimatedDurationMinutes: estimatedDurationMinutes,
                isCompleted: isCompleted,
                completedAt: completedAt,
                sortOrder: sortOrder,
                sourceKind: sourceKind,
                sourceRef: sourceRef,
                courseTimetableId: courseTimetableId,
                courseSourceKind: courseSourceKind,
                courseSourceCourseId: courseSourceCourseId,
                courseNature: courseNature,
                instructor: instructor,
                weekMeta: weekMeta,
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
                required DateTime startAt,
                required DateTime endAt,
                Value<bool> isAllDay = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<int> estimatedDurationMinutes = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<String> sourceRef = const Value.absent(),
                Value<String> courseTimetableId = const Value.absent(),
                Value<String> courseSourceKind = const Value.absent(),
                Value<String> courseSourceCourseId = const Value.absent(),
                Value<String> courseNature = const Value.absent(),
                Value<String> instructor = const Value.absent(),
                Value<String> weekMeta = const Value.absent(),
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
                startAt: startAt,
                endAt: endAt,
                isAllDay: isAllDay,
                deadline: deadline,
                estimatedDurationMinutes: estimatedDurationMinutes,
                isCompleted: isCompleted,
                completedAt: completedAt,
                sortOrder: sortOrder,
                sourceKind: sourceKind,
                sourceRef: sourceRef,
                courseTimetableId: courseTimetableId,
                courseSourceKind: courseSourceKind,
                courseSourceCourseId: courseSourceCourseId,
                courseNature: courseNature,
                instructor: instructor,
                weekMeta: weekMeta,
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        AgendaItemRow,
        BaseReferences<_$AppDatabase, $AgendaItemRowsTable, AgendaItemRow>,
      ),
      AgendaItemRow,
      PrefetchHooks Function()
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
