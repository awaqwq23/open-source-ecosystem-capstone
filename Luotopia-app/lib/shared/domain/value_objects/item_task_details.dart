class ItemTaskDetails {
  const ItemTaskDetails({
    required this.deadline,
    this.estimatedDuration = Duration.zero,
  });

  final DateTime? deadline;
  final Duration estimatedDuration;

  ItemTaskDetails copyWith({
    DateTime? deadline,
    bool clearDeadline = false,
    Duration? estimatedDuration,
  }) {
    return ItemTaskDetails(
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }
}
