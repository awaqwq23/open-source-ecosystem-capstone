import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/app/shell/app_shell.dart';
import 'package:huajuan_agenda/core/motion/app_route_transitions.dart';
import 'package:huajuan_agenda/features/ai/presentation/pages/ai_page.dart';
import 'package:huajuan_agenda/features/home/presentation/pages/home_page.dart';
import 'package:huajuan_agenda/features/item_detail/domain/models/item_detail_args.dart';
import 'package:huajuan_agenda/features/item_detail/presentation/pages/item_detail_page.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_args.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/features/item_editor/presentation/pages/item_editor_page.dart';
import 'package:huajuan_agenda/features/item_editor/presentation/pages/reminder_settings_page.dart';
import 'package:huajuan_agenda/features/item_editor/presentation/pages/repeat_settings_page.dart';
import 'package:huajuan_agenda/features/list/presentation/pages/list_page.dart';
import 'package:huajuan_agenda/features/settings/presentation/pages/settings_page.dart';
import 'package:huajuan_agenda/features/time_picker/domain/models/time_picker_args.dart';
import 'package:huajuan_agenda/features/time_picker/presentation/pages/time_picker_page.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutePaths.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.list,
                builder: (context, state) => const ListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.ai,
                builder: (context, state) => const AiPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.itemEditor,
                builder: (context, state) => ItemEditorPage(
                  args: switch (state.extra) {
                    final ItemEditorArgs args => args,
                    final ItemEditorPrefill prefill => ItemEditorArgs(prefill: prefill),
                    _ => null,
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePaths.itemDetail,
        pageBuilder: (context, state) => AppRouteTransitions.sharedAxisPage<void>(
          context,
          state,
          ItemDetailPage(
            args: state.extra is ItemDetailArgs
                ? state.extra! as ItemDetailArgs
                : null,
          ),
          type: SharedAxisTransitionType.scaled,
        ),
      ),
      GoRoute(
        path: AppRoutePaths.timePicker,
        pageBuilder: (context, state) => AppRouteTransitions.fadeThroughPage<void>(
          context,
          state,
          TimePickerPage(
            args: state.extra is TimePickerArgs ? state.extra! as TimePickerArgs : null,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.repeatSettings,
        pageBuilder: (context, state) => AppRouteTransitions.sharedAxisPage<RepeatRule>(
          context,
          state,
          RepeatSettingsPage(
            initialRule:
                state.extra is RepeatRule ? state.extra! as RepeatRule : RepeatRule.none,
          ),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: AppRoutePaths.reminderSettings,
        pageBuilder: (context, state) =>
            AppRouteTransitions.sharedAxisPage<ReminderOption>(
          context,
          state,
          ReminderSettingsPage(
            initialReminder: state.extra is ReminderOption
                ? state.extra! as ReminderOption
                : ReminderOption.none,
          ),
          type: SharedAxisTransitionType.horizontal,
        ),
      ),
    ],
  );
});
