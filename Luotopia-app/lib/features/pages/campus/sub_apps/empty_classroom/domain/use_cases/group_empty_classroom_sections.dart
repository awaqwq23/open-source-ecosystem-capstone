class GroupEmptyClassroomSectionsUseCase {
  const GroupEmptyClassroomSectionsUseCase();

  List<List<int>> call(List<int> sections) {
    if (sections.isEmpty) {
      return const [];
    }
    final sorted = [...sections]..sort();
    final groups = <List<int>>[];
    var current = <int>[sorted.first];
    for (var index = 1; index < sorted.length; index++) {
      final section = sorted[index];
      if (section == current.last + 1) {
        current.add(section);
        continue;
      }
      groups.add(current);
      current = <int>[section];
    }
    groups.add(current);
    return groups;
  }
}
