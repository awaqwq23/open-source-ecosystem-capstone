class ItemMemoDetails {
  const ItemMemoDetails({
    required this.targetDate,
    required this.estimatedDuration,
  });

  final DateTime targetDate;
  final Duration estimatedDuration;

  ItemMemoDetails copyWith({
    DateTime? targetDate,
    Duration? estimatedDuration,
  }) {
    return ItemMemoDetails(
      targetDate: targetDate ?? this.targetDate,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }
}
