import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/app/shell/app_shell.dart';
import 'package:luotopia/core/motion/app_motion.dart';
import 'package:luotopia/core/motion/app_route_transitions.dart';
import 'package:luotopia/features/pages/campus/sub_apps/timetable/course_import/presentation/pages/course_import_wakeup_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/timetable/course_import/presentation/pages/course_import_whu_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/timetable/course_import/presentation/pages/course_timetables_page.dart';
import 'package:luotopia/features/luotopia_auth/presentation/pages/luotopia_account_page.dart';
import 'package:luotopia/features/luotopia_auth/presentation/pages/luotopia_login_page.dart';
import 'package:luotopia/features/whu_auth/presentation/pages/whu_account_detail_page.dart';
import 'package:luotopia/features/whu_auth/presentation/pages/whu_login_webview_page.dart';
import 'package:luotopia/features/pages/campus/presentation/pages/campus_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/pages/all_school_timetable_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/pages/course_head_classes_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/presentation/pages/teaching_class_detail_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/presentation/pages/empty_classroom_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/luojia_ecard/presentation/pages/luojia_ecard_webview_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/score/presentation/pages/score_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/seat_reservation/presentation/pages/seat_reservation_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_session.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/domain/sports_reservation_domain.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/presentation/pages/sports_reservation_checkout_webview_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/presentation/pages/sports_reservation_order_webview_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/presentation/pages/sports_reservation_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/presentation/pages/sports_reservation_session_webview_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/timetable/presentation/pages/campus_timetable_page.dart';
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
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_ai_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_course_grid_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_data_updates_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_general_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_home_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_navigation_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_page.dart';
import 'package:luotopia/features/pages/settings/presentation/pages/settings_time_grid_page.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final navSettings = ref.read(appNavigationSettingsProvider);
  return GoRouter(
    initialLocation: navSettings.defaultTab,
    routes: [
      StatefulShellRoute(
        navigatorContainerBuilder: (context, navigationShell, children) {
          return AnimatedSwitcher(
            duration: AppMotion.slow,
            switchInCurve: AppMotion.enterCurve,
            switchOutCurve: AppMotion.exitCurve,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: children[navigationShell.currentIndex],
          );
        },
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
                  autoFocusInput:
                      state.uri.queryParameters['focusInput'] == '1',
                ),
                routes: [
                  GoRoute(
                    path: 'sessions',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const AiSessionsPage(),
                        ),
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
                routes: [
                  GoRoute(
                    path: 'score',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const ScorePage(),
                        ),
                  ),
                  GoRoute(
                    path: 'timetable',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const CampusTimetablePage(),
                        ),
                    routes: [
                      GoRoute(
                        path: 'manage',
                        pageBuilder: (context, state) =>
                            AppRouteTransitions.sharedAxisPage<void>(
                              context,
                              state,
                              const CourseTimetablesPage(),
                            ),
                      ),
                      GoRoute(
                        path: 'import/whu',
                        pageBuilder: (context, state) =>
                            AppRouteTransitions.sharedAxisPage<void>(
                              context,
                              state,
                              const CourseImportWhuPage(),
                            ),
                      ),
                      GoRoute(
                        path: 'import/wakeup',
                        pageBuilder: (context, state) =>
                            AppRouteTransitions.sharedAxisPage<void>(
                              context,
                              state,
                              const CourseImportWakeupPage(),
                            ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'seat-reservation',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const SeatReservationPage(),
                        ),
                  ),
                  GoRoute(
                    path: 'sports-reservation',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const SportsReservationPage(),
                        ),
                  ),
                  GoRoute(
                    path: 'sports-reservation/session',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<
                          SportsReservationSession
                        >(
                          context,
                          state,
                          const SportsReservationSessionWebViewPage(),
                        ),
                  ),
                  GoRoute(
                    path: 'sports-reservation/checkout',
                    pageBuilder: (context, state) {
                      final args = state.extra;
                      return AppRouteTransitions.sharedAxisPage<
                        SportsCheckoutResult
                      >(
                        context,
                        state,
                        args is SportsCheckoutArgs
                            ? SportsReservationCheckoutWebViewPage(args: args)
                            : const _MissingSportsCheckoutArgsPage(),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'sports-reservation/order',
                    pageBuilder: (context, state) {
                      final args = state.extra;
                      return AppRouteTransitions.sharedAxisPage<void>(
                        context,
                        state,
                        args is SportsReservationOrderWebViewArgs
                            ? SportsReservationOrderWebViewPage(args: args)
                            : const _MissingSportsOrderArgsPage(),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'luojia-ecard',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const LuojiaEcardWebViewPage(
                            entry: LuojiaEcardEntry.card,
                          ),
                        ),
                  ),
                  GoRoute(
                    path: 'ecard-payment-code',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const LuojiaEcardWebViewPage(
                            entry: LuojiaEcardEntry.paymentCode,
                          ),
                        ),
                  ),
                  GoRoute(
                    path: 'empty-classroom',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const EmptyClassroomPage(),
                        ),
                  ),
                  GoRoute(
                    path: 'all-school-timetable',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const AllSchoolTimetablePage(),
                        ),
                  ),
                  GoRoute(
                    path: 'all-school-timetable/head',
                    pageBuilder: (context, state) {
                      final args = state.extra;
                      return AppRouteTransitions.sharedAxisPage<void>(
                        context,
                        state,
                        args is CourseHeadPageArgs
                            ? CourseHeadClassesPage(args: args)
                            : const _MissingAllSchoolTimetableArgsPage(),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'all-school-timetable/class',
                    pageBuilder: (context, state) {
                      final args = state.extra;
                      return AppRouteTransitions.sharedAxisPage<void>(
                        context,
                        state,
                        args is TeachingClassDetailPageArgs
                            ? TeachingClassDetailPage(args: args)
                            : const _MissingAllSchoolTimetableArgsPage(),
                      );
                    },
                  ),
                ],
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
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const SettingsGeneralPage(),
                        ),
                  ),
                  GoRoute(
                    path: 'navigation',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const SettingsNavigationPage(),
                        ),
                  ),
                  GoRoute(
                    path: 'data-updates',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const SettingsDataUpdatesPage(),
                        ),
                  ),
                  GoRoute(
                    path: 'home',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const SettingsHomePage(),
                        ),
                  ),
                  GoRoute(
                    path: 'time-grid',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const SettingsTimeGridPage(),
                        ),
                  ),
                  GoRoute(
                    path: 'course-grid',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const SettingsCourseGridPage(),
                        ),
                  ),
                  GoRoute(
                    path: 'ai',
                    pageBuilder: (context, state) =>
                        AppRouteTransitions.sharedAxisPage<void>(
                          context,
                          state,
                          const SettingsAiPage(),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePaths.whuAccount,
        pageBuilder: (context, state) =>
            AppRouteTransitions.sharedAxisPage<void>(
              context,
              state,
              const WhuAccountDetailPage(),
            ),
      ),
      GoRoute(
        path: AppRoutePaths.whuAccountLogin,
        pageBuilder: (context, state) =>
            AppRouteTransitions.sharedAxisPage<void>(
              context,
              state,
              const WhuLoginWebViewPage(),
            ),
      ),
      GoRoute(
        path: AppRoutePaths.luotopiaLogin,
        pageBuilder: (context, state) =>
            AppRouteTransitions.sharedAxisPage<void>(
              context,
              state,
              const LuotopiaLoginPage(),
            ),
      ),
      GoRoute(
        path: AppRoutePaths.luotopiaAccount,
        pageBuilder: (context, state) =>
            AppRouteTransitions.sharedAxisPage<void>(
              context,
              state,
              const LuotopiaAccountPage(),
            ),
        routes: [
          GoRoute(
            path: 'settings',
            pageBuilder: (context, state) =>
                AppRouteTransitions.sharedAxisPage<void>(
                  context,
                  state,
                  const LuotopiaAccountSettingsPage(),
                ),
            routes: [
              GoRoute(
                path: 'username',
                pageBuilder: (context, state) =>
                    AppRouteTransitions.sharedAxisPage<void>(
                      context,
                      state,
                      const LuotopiaUsernamePage(),
                    ),
              ),
              GoRoute(
                path: 'password',
                pageBuilder: (context, state) =>
                    AppRouteTransitions.sharedAxisPage<void>(
                      context,
                      state,
                      const LuotopiaPasswordPage(),
                    ),
              ),
              GoRoute(
                path: 'phone',
                pageBuilder: (context, state) =>
                    AppRouteTransitions.sharedAxisPage<void>(
                      context,
                      state,
                      const LuotopiaPhonePage(),
                    ),
              ),
              GoRoute(
                path: 'email',
                pageBuilder: (context, state) =>
                    AppRouteTransitions.sharedAxisPage<void>(
                      context,
                      state,
                      const LuotopiaEmailPage(),
                    ),
              ),
              GoRoute(
                path: 'wechat',
                pageBuilder: (context, state) =>
                    AppRouteTransitions.sharedAxisPage<void>(
                      context,
                      state,
                      const LuotopiaSocialBindPage(providerName: '微信'),
                    ),
              ),
              GoRoute(
                path: 'qq',
                pageBuilder: (context, state) =>
                    AppRouteTransitions.sharedAxisPage<void>(
                      context,
                      state,
                      const LuotopiaSocialBindPage(providerName: 'QQ'),
                    ),
              ),
            ],
          ),
          GoRoute(
            path: 'devices',
            pageBuilder: (context, state) =>
                AppRouteTransitions.sharedAxisPage<void>(
                  context,
                  state,
                  const LuotopiaDeviceManagementPage(),
                ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePaths.itemEditorFlow,
        pageBuilder: (context, state) =>
            AppRouteTransitions.sharedAxisPage<void>(
              context,
              state,
              ProviderScope(
                key: state.pageKey,
                child: ItemEditorPage(
                  args: _resolveItemEditorArgs(state),
                  autoPopOnSubmit: true,
                ),
              ),
            ),
      ),
      GoRoute(
        path: AppRoutePaths.itemDetail,
        pageBuilder: (context, state) =>
            AppRouteTransitions.sharedAxisPage<void>(
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
        pageBuilder: (context, state) =>
            AppRouteTransitions.sharedAxisPage<RepeatRule>(
              context,
              state,
              RepeatSettingsPage(
                initialRule: state.extra is RepeatRule
                    ? state.extra! as RepeatRule
                    : RepeatRule.none,
              ),
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
  final presetType = _parsePresetType(state.uri.queryParameters['presetType']);
  final presetPrefill = presetType == null
      ? null
      : ItemEditorPrefill(type: presetType);

  return switch (state.extra) {
    final ItemEditorArgs value => value.copyWith(
      showTypePickerOnLaunch: showTypePicker,
      prefill: presetPrefill ?? value.prefill,
    ),
    final ItemEditorPrefill prefill => ItemEditorArgs(
      prefill: presetPrefill ?? prefill,
      showTypePickerOnLaunch: showTypePicker,
    ),
    _ =>
      (showTypePicker || presetPrefill != null)
          ? ItemEditorArgs(
              prefill: presetPrefill,
              showTypePickerOnLaunch: showTypePicker,
            )
          : null,
  };
}

class _MissingSportsCheckoutArgsPage extends StatelessWidget {
  const _MissingSportsCheckoutArgsPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('预约确认参数缺失，请返回重新选择。'));
  }
}

class _MissingSportsOrderArgsPage extends StatelessWidget {
  const _MissingSportsOrderArgsPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('订单参数缺失，请返回重新选择。'));
  }
}

class _MissingAllSchoolTimetableArgsPage extends StatelessWidget {
  const _MissingAllSchoolTimetableArgsPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('课表参数缺失，请返回重新选择。'));
  }
}
