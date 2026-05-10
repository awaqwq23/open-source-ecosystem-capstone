import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDurationPicker {
  const AppDurationPicker._();

  static Future<Duration?> pickDuration(
    BuildContext context, {
    required Duration initialDuration,
    int maxHours = 24,
    int minuteInterval = 5,
  }) {
    final initialMinutes = initialDuration.inMinutes;
    var selectedHours = (initialMinutes ~/ 60).clamp(0, maxHours).toInt();
    var selectedMinutes = initialMinutes % 60;
    selectedMinutes = (selectedMinutes / minuteInterval).round() * minuteInterval;
    if (selectedMinutes >= 60) {
      selectedMinutes = 0;
      selectedHours = (selectedHours + 1).clamp(0, maxHours).toInt();
    }

    final hourController = FixedExtentScrollController(initialItem: selectedHours);
    final minuteValues = [
      for (var minute = 0; minute < 60; minute += minuteInterval) minute,
    ];
    final minuteController = FixedExtentScrollController(
      initialItem: minuteValues
          .indexOf(selectedMinutes)
          .clamp(0, minuteValues.length - 1)
          .toInt(),
    );

    return showModalBottomSheet<Duration>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final isZh = Localizations.localeOf(sheetContext)
            .languageCode
            .toLowerCase()
            .startsWith('zh');
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selectedDuration = Duration(
              hours: selectedHours,
              minutes: selectedMinutes,
            );
            final canConfirm = selectedDuration > Duration.zero;
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                        ),
                        const Spacer(),
                        Text(
                          isZh ? '选择时长' : 'Choose duration',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: canConfirm
                              ? () => Navigator.of(sheetContext).pop(selectedDuration)
                              : null,
                          child: Text(MaterialLocalizations.of(context).okButtonLabel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: hourController,
                              itemExtent: 44,
                              onSelectedItemChanged: (index) {
                                setSheetState(() => selectedHours = index);
                              },
                              children: [
                                for (var hour = 0; hour <= maxHours; hour++)
                                  Center(child: Text(isZh ? '$hour 小时' : '$hour h')),
                              ],
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: minuteController,
                              itemExtent: 44,
                              onSelectedItemChanged: (index) {
                                setSheetState(() => selectedMinutes = minuteValues[index]);
                              },
                              children: [
                                for (final minute in minuteValues)
                                  Center(child: Text(isZh ? '$minute 分钟' : '$minute min')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      hourController.dispose();
      minuteController.dispose();
    });
  }
}
