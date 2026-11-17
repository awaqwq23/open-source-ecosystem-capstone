class CoursePeriodTime {
  const CoursePeriodTime({
    required this.period,
    required this.startMinute,
    required this.endMinute,
  });

  final int period;
  final int startMinute;
  final int endMinute;
}

class CoursePeriodSchedule {
  const CoursePeriodSchedule._();

  static const periods = <CoursePeriodTime>[
    CoursePeriodTime(period: 1, startMinute: 480, endMinute: 525),
    CoursePeriodTime(period: 2, startMinute: 530, endMinute: 575),
    CoursePeriodTime(period: 3, startMinute: 590, endMinute: 635),
    CoursePeriodTime(period: 4, startMinute: 640, endMinute: 685),
    CoursePeriodTime(period: 5, startMinute: 690, endMinute: 735),
    CoursePeriodTime(period: 6, startMinute: 845, endMinute: 890),
    CoursePeriodTime(period: 7, startMinute: 895, endMinute: 940),
    CoursePeriodTime(period: 8, startMinute: 945, endMinute: 990),
    CoursePeriodTime(period: 9, startMinute: 1000, endMinute: 1045),
    CoursePeriodTime(period: 10, startMinute: 1050, endMinute: 1095),
    CoursePeriodTime(period: 11, startMinute: 1110, endMinute: 1155),
    CoursePeriodTime(period: 12, startMinute: 1160, endMinute: 1205),
    CoursePeriodTime(period: 13, startMinute: 1210, endMinute: 1255),
  ];

  static CoursePeriodTime? period(int period) {
    for (final time in periods) {
      if (time.period == period) {
        return time;
      }
    }
    return null;
  }
}
