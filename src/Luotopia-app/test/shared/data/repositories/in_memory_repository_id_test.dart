import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/pages/item_editor/domain/item_editor_defaults.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:luotopia/shared/data/id/app_id_generator.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';

void main() {
  group('InMemoryAgendaItemRepository IDs', () {
    test('新建事项使用带 item 前缀的唯一 ID', () async {
      final database = AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appIdGeneratorProvider.overrideWithValue(
            _FakeAppIdGenerator(agendaIds: ['item_alpha', 'item_beta']),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(agendaItemRepositoryProvider.notifier);
      final first = await repository.createItem(_draft('第一项'));
      final second = await repository.createItem(_draft('第二项'));

      expect(first.id, 'item_alpha');
      expect(second.id, 'item_beta');
      expect(first.id, startsWith('item_'));
      expect(second.id, startsWith('item_'));
      expect(first.id, isNot(second.id));
    });

    test('删除事项后新建不会复用已有 ID', () async {
      final database = AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appIdGeneratorProvider.overrideWithValue(
            _FakeAppIdGenerator(agendaIds: ['item_0', 'item_1', 'item_2']),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(agendaItemRepositoryProvider.notifier);
      final first = await repository.createItem(_draft('第一项'));
      final second = await repository.createItem(_draft('第二项'));

      await repository.deleteItem(first.id);
      final third = await repository.createItem(_draft('第三项'));

      expect(second.id, 'item_1');
      expect(third.id, 'item_2');
      expect(third.id, isNot(second.id));
    });

    test('生成器偶发碰撞时跳过已有事项 ID', () async {
      final database = AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appIdGeneratorProvider.overrideWithValue(
            _FakeAppIdGenerator(agendaIds: ['item_same', 'item_same', 'item_next']),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(agendaItemRepositoryProvider.notifier);
      final first = await repository.createItem(_draft('第一项'));
      final second = await repository.createItem(_draft('第二项'));

      expect(first.id, 'item_same');
      expect(second.id, 'item_next');
      expect(
        (await database.select(database.agendaItemRows).get())
            .map((row) => row.id)
            .toSet(),
        {'item_same', 'item_next'},
      );
    });
  });

  group('InMemoryCourseTimetableRepository IDs', () {
    test('新建课程表使用带 timetable 前缀的唯一 ID', () async {
      final database = AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appIdGeneratorProvider.overrideWithValue(
            _FakeAppIdGenerator(timetableIds: ['timetable_alpha', 'timetable_beta']),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(courseTimetableRepositoryProvider.notifier);
      final first = await repository.createTimetable(
        name: '主课程表',
        source: CourseTimetableSource.manual,
      );
      final second = await repository.createTimetable(
        name: '辅课程表',
        source: CourseTimetableSource.manual,
      );

      expect(first.id, 'timetable_alpha');
      expect(second.id, 'timetable_beta');
      expect(first.id, startsWith('timetable_'));
      expect(second.id, startsWith('timetable_'));
      expect(first.id, isNot(second.id));
    });

    test('生成器偶发碰撞时跳过已有课程表 ID', () async {
      final database = AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appIdGeneratorProvider.overrideWithValue(
            _FakeAppIdGenerator(
              timetableIds: ['timetable_same', 'timetable_same', 'timetable_next'],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(courseTimetableRepositoryProvider.notifier);
      final first = await repository.createTimetable(
        name: '主课程表',
        source: CourseTimetableSource.manual,
      );
      final second = await repository.createTimetable(
        name: '辅课程表',
        source: CourseTimetableSource.manual,
      );

      expect(first.id, 'timetable_same');
      expect(second.id, 'timetable_next');
      expect(
        (await database.select(database.courseTimetableRows).get())
            .map((row) => row.id)
            .toSet(),
        {'timetable_same', 'timetable_next'},
      );
    });
  });
}

ItemDraft _draft(String title) {
  return ItemEditorDefaults.createDraft().copyWith(title: title);
}

class _FakeAppIdGenerator implements AppIdGenerator {
  _FakeAppIdGenerator({
    List<String> agendaIds = const [],
    List<String> timetableIds = const [],
  })  : _agendaIds = List.of(agendaIds),
        _timetableIds = List.of(timetableIds);

  final List<String> _agendaIds;
  final List<String> _timetableIds;

  @override
  String newAgendaItemId() {
    if (_agendaIds.isEmpty) {
      throw StateError('没有更多事项 ID');
    }
    return _agendaIds.removeAt(0);
  }

  @override
  String newCourseTimetableId() {
    if (_timetableIds.isEmpty) {
      throw StateError('没有更多课程表 ID');
    }
    return _timetableIds.removeAt(0);
  }
}
