import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/app/shell/app_shell.dart';
import 'package:luotopia/core/motion/app_route_transitions.dart';
import 'package:luotopia/features/components/course_import/presentation/pages/course_import_wakeup_page.dart';
import 'package:luotopia/features/components/course_import/presentation/pages/course_import_whu_page.dart';
import 'package:luotopia/features/components/course_import/presentation/pages/course_timetables_page.dart';
import 'package:luotopia/features/whu_auth/presentation/pages/whu_login_webview_page.dart';
import 'package:luotopia/features/pages/campus/presentation/pages/campus_page.dart';
import 'package:luotopia/features/pages/forum/presentation/pages/forum_page.dart';
import 'package:luotopia/features/pages/ai/presentation/pages/ai_page.dart';
import 'package:luotopia/features/pages/home/presentation/pages/home_page.dart';
import 'package:luotopia/features/pages/item_detail/domain/models/item_detail_args.dart';
import 'package:luotopia/features/pages/item_detail/presentation/pages/item_detail_page.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_args.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_prefill.dart';
import 'package:luotopia/features/pages/item_editor/presentation/pages/item_editor_page.dart';
import 'package:luotopia/features/pages/item_editor/presentation/pages/reminder_settings_page.dart';
import 'package:luotopia/features/pages/item_editor/presentation/pages/repeat_settings_page.dart';
import 'package:luotopia/features/pages/list/presentation/pages/list_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_about_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_ai_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_general_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_home_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_list_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_widgets_page.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

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
                path: AppRoutePaths.forum,
                builder: (context, state) => const ForumPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.ai,
                builder: (context, state) => AiPage(
                  autoFocusInput: state.uri.queryParameters['focusInput'] == '1',
                ),
                routes: [
                  GoRoute(
                    path: 'sessions',
                    builder: (context, state) => const AiSessionsPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.campus,
                builder: (context, state) => const CampusPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.settings,
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'general',
                    builder: (context, state) => const SettingsGeneralPage(),
                  ),
                  GoRoute(
                    path: 'widgets',
                    builder: (context, state) => const SettingsWidgetsPage(),
                  ),
                  GoRoute(
                    path: 'home',
                    builder: (context, state) => const SettingsHomePage(),
                  ),
                  GoRoute(
                    path: 'list',
                    builder: (context, state) => const SettingsListPage(),
                  ),
                  GoRoute(
                    path: 'course-timetables',
                    builder: (context, state) => const CourseTimetablesPage(),
                  ),
                  GoRoute(
                    path: 'course-import-whu',
                    builder: (context, state) => const CourseImportWhuPage(),
                  ),
                  GoRoute(
                    path: 'whu-auth/login',
                    builder: (context, state) => const WhuLoginWebViewPage(),
                  ),
                  GoRoute(
                    path: 'course-import-wakeup',
                    builder: (context, state) => const CourseImportWakeupPage(),
                  ),
                  GoRoute(
                    path: 'ai',
                    builder: (context, state) => const SettingsAiPage(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const SettingsAboutPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePaths.itemEditorFlow,
        pageBuilder: (context, state) => AppRouteTransitions.sharedAxisPage<void>(
          context,
          state,
          ProviderScope(
            key: state.pageKey,
            child: ItemEditorPage(
              args: _resolveItemEditorArgs(state),
              autoPopOnSubmit: true,
            ),
          ),
          type: SharedAxisTransitionType.horizontal,
        ),
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

ItemType? _parsePresetType(String? value) {
  return switch (value?.toLowerCase().trim()) {
    'schedule' => ItemType.schedule,
    'task' => ItemType.task,
    'memo' => ItemType.memo,
    _ => null,
  };
}

ItemEditorArgs? _resolveItemEditorArgs(GoRouterState state) {
  final showTypePicker = state.uri.queryParameters['showTypePicker'] == '1';
  final presetType = _parsePresetType(
    state.uri.queryParameters['presetType'],
  );
  final presetPrefill = presetType == null ? null : ItemEditorPrefill(type: presetType);

  return switch (state.extra) {
    final ItemEditorArgs value => value.copyWith(
        showTypePickerOnLaunch: showTypePicker,
        prefill: presetPrefill ?? value.prefill,
      ),
    final ItemEditorPrefill prefill => ItemEditorArgs(
        prefill: presetPrefill ?? prefill,
        showTypePickerOnLaunch: showTypePicker,
      ),
    _ => (showTypePicker || presetPrefill != null)
        ? ItemEditorArgs(
            prefill: presetPrefill,
            showTypePickerOnLaunch: showTypePicker,
          )
        : null,
  };
}
