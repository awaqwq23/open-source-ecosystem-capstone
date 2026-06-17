import 'package:flutter/material.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/presentation/viewmodels/empty_classroom_view_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class EmptyClassroomFilterCard extends StatelessWidget {
  const EmptyClassroomFilterCard({
    required this.state,
    required this.onCampusChanged,
    required this.onBuildingChanged,
    required this.onWeekChanged,
    required this.onWeekDayChanged,
    super.key,
  });

  final EmptyClassroomState state;
  final ValueChanged<CampusBuilding?> onCampusChanged;
  final ValueChanged<Building?> onBuildingChanged;
  final ValueChanged<String> onWeekChanged;
  final ValueChanged<String> onWeekDayChanged;

  static const _weekDays = ['1', '2', '3', '4', '5', '6', '7'];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final materialL10n = MaterialLocalizations.of(context);

    return ui.Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.emptyClassroomFilterTitle,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CampusBuilding>(
            key: ValueKey('campus_${state.campuses.length}'),
            initialValue: state.selectedCampus,
            decoration: InputDecoration(
              labelText: l10n.emptyClassroomFilterCampus,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: state.campuses
                .map(
                  (campus) => DropdownMenuItem(
                    value: campus,
                    child: Text(campus.campus),
                  ),
                )
                .toList(),
            onChanged: onCampusChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Building>(
            key: ValueKey('building_${state.selectedCampus?.campus}'),
            initialValue: state.selectedBuilding,
            decoration: InputDecoration(
              labelText: l10n.emptyClassroomFilterBuilding,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            hint: const Text('全部教学楼'),
            items: [
              const DropdownMenuItem<Building>(
                value: null,
                child: Text('全部教学楼'),
              ),
              ...state.buildings.map(
                (building) => DropdownMenuItem(
                  value: building,
                  child: Text(building.name),
                ),
              ),
            ],
            onChanged: state.selectedCampus == null ? null : onBuildingChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: state.weeks.contains(state.selectedWeek)
                      ? state.selectedWeek
                      : null,
                  decoration: InputDecoration(
                    labelText: l10n.emptyClassroomFilterWeek,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: state.weeks
                      .map(
                        (week) => DropdownMenuItem(
                          value: week,
                          child: Text(l10n.emptyClassroomWeekLabel(week)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onWeekChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _weekDays.contains(state.selectedWeekDay)
                      ? state.selectedWeekDay
                      : null,
                  decoration: InputDecoration(
                    labelText: l10n.emptyClassroomFilterWeekDay,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: _weekDays.map((day) {
                    final index = int.tryParse(day) ?? 1;
                    return DropdownMenuItem(
                      value: day,
                      child: Text(materialL10n.narrowWeekdays[index % 7]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onWeekDayChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
