import 'package:flutter_test/flutter_test.dart';
import 'package:huajuan_agenda/features/pages/home/presentation/layout/home_grid_metrics.dart';

void main() {
  test('时间列宽度固定为单元格宽度的 0.7 倍', () {
    const cellWidth = 46.0;

    final timelineWidth = HomeGridMetrics.computeTimelineWidth(cellWidth: cellWidth);

    expect(timelineWidth, cellWidth * HomeGridMetrics.timelineWidthFactor);
  });

  test('表格列宽计算会把时间列占比一起纳入', () {
    const availableWidth = 360.0;
    const columnCount = 7;
    const columnGap = 2.0;
    const minimumColumnWidth = 18.0;

    final columnWidth = HomeGridMetrics.computeColumnWidth(
      availableWidth: availableWidth,
      columnCount: columnCount,
      columnGap: columnGap,
      minimumColumnWidth: minimumColumnWidth,
    );
    final timelineWidth = HomeGridMetrics.computeTimelineWidth(cellWidth: columnWidth);
    final occupiedWidth =
        timelineWidth + columnWidth * columnCount + columnGap * columnCount;

    expect(occupiedWidth, closeTo(availableWidth, 0.0001));
  });

  test('极窄宽度下仍会保持最小单元格宽度', () {
    const minimumColumnWidth = 18.0;

    final columnWidth = HomeGridMetrics.computeColumnWidth(
      availableWidth: 80.0,
      columnCount: 7,
      columnGap: 2.0,
      minimumColumnWidth: minimumColumnWidth,
    );

    expect(columnWidth, minimumColumnWidth);
    expect(
      HomeGridMetrics.computeTimelineWidth(cellWidth: columnWidth),
      minimumColumnWidth * HomeGridMetrics.timelineWidthFactor,
    );
  });
}
