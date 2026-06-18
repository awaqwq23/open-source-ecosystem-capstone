import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'course_schedule_database.dart';

/// Seeds the course schedule database from a bundled JSON asset.
class CourseScheduleSeeder {
  const CourseScheduleSeeder(this._db);

  final CourseScheduleDatabase _db;

  /// Returns true if fresh seeding was done.
  Future<bool> seedIfNeeded() async {
    if (await _db.hasData()) return false;

    final jsonStr = await rootBundle.loadString(
      'assets/course_schedule/2025-2026-1.json',
    );
    final List<dynamic> records = json.decode(jsonStr) as List<dynamic>;

    // Batch insert in transactions for speed
    const batchSize = 500;
    for (var i = 0; i < records.length; i += batchSize) {
      final batch = records.sublist(
        i,
        i + batchSize > records.length ? records.length : i + batchSize,
      );
      await _insertBatch(batch);
    }
    return true;
  }

  Future<void> _insertBatch(List<dynamic> batch) async {
    // Build a bulk INSERT statement
    final sb = StringBuffer();
    sb.write('''
      INSERT INTO course_schedule_classes (
        academic_year, semester, course_code, course_name,
        teaching_class_name, school, plan_school, credits,
        course_nature, course_category, course_type, grade, major,
        teacher, teacher_title, student_count,
        theory_hours, computer_hours, experiment_hours, practice_hours,
        schedule_sun, schedule_mon, schedule_tue, schedule_wed,
        schedule_thu, schedule_fri, schedule_sat,
        notes, other_teachers, textbook, publisher
      ) VALUES
    ''');

    final allArgs = <Object?>[];
    for (var i = 0; i < batch.length; i++) {
      if (i > 0) sb.write(',');
      sb.write('''(
        ?,?,?,?,
        ?,?,?,?,
        ?,?,?,?,?,
        ?,?,?,
        ?,?,?,?,
        ?,?,?,?,
        ?,?,?,
        ?,?,?,?
      )''');
      final r = batch[i] as Map<String, dynamic>;
      allArgs.addAll([
        r['academic_year'] ?? '',
        r['semester'] ?? 0,
        r['course_code'] ?? '',
        r['course_name'] ?? '',
        r['teaching_class_name'] ?? '',
        r['school'] ?? '',
        r['plan_school'] ?? '',
        r['credits'] ?? 0,
        r['course_nature'] ?? '',
        r['course_category'] ?? '',
        r['course_type'] ?? '',
        r['grade'] ?? '',
        r['major'] ?? '',
        r['teacher'] ?? '',
        r['teacher_title'] ?? '',
        r['student_count'] ?? '',
        r['theory_hours'],
        r['computer_hours'],
        r['experiment_hours'],
        r['practice_hours'],
        r['schedule_sun'],
        r['schedule_mon'],
        r['schedule_tue'],
        r['schedule_wed'],
        r['schedule_thu'],
        r['schedule_fri'],
        r['schedule_sat'],
        r['notes'],
        r['other_teachers'],
        r['textbook'],
        r['publisher'],
      ]);
    }
    await _db.rawInsert(sb.toString(), allArgs);
  }
}
