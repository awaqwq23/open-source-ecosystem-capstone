class FormatEmptyClassroomSectionsUseCase {
  const FormatEmptyClassroomSectionsUseCase();

  String call(List<int> sections) {
    if (sections.isEmpty) {
      return '';
    }
    final sorted = [...sections]..sort();
    final groups = <String>[];
    var start = sorted.first;
    var previous = start;
    for (var index = 1; index < sorted.length; index++) {
      final section = sorted[index];
      if (section == previous + 1) {
        previous = section;
        continue;
      }
      groups.add(start == previous ? '$start' : '$start-$previous');
      start = section;
      previous = section;
    }
    groups.add(start == previous ? '$start' : '$start-$previous');
    return '第${groups.join(',')}节';
  }
}
