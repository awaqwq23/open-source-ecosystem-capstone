import 'package:flutter/material.dart';

class AppDateTimePickers {
  const AppDateTimePickers._();

  static Future<DateTime?> pickDate(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
  }) {
    return showDatePicker(
      context: context,
      initialDate: DateUtils.dateOnly(initialDate),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      initialDatePickerMode: initialDatePickerMode,
    );
  }

  static Future<TimeOfDay?> pickTime(
    BuildContext context, {
    required TimeOfDay initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  static Future<DateTime?> pickDateTime(
    BuildContext context, {
    required DateTime initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final pickedDate = await pickDate(
      context,
      initialDate: initialDateTime,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate == null || !context.mounted) {
      return null;
    }

    final pickedTime = await pickTime(
      context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );
    if (pickedTime == null) {
      return null;
    }

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
}
