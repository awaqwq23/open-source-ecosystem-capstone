import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/app/shell/app_shell.dart';
import 'package:huajuan_agenda/features/ai/presentation/pages/ai_page.dart';
import 'package:huajuan_agenda/features/home/presentation/pages/home_page.dart';
import 'package:huajuan_agenda/features/item_detail/presentation/pages/item_detail_page.dart';
import 'package:huajuan_agenda/features/item_editor/presentation/pages/item_editor_page.dart';
import 'package:huajuan_agenda/features/list/presentation/pages/list_page.dart';
import 'package:huajuan_agenda/features/settings/presentation/pages/settings_page.dart';
import 'package:huajuan_agenda/features/time_picker/presentation/pages/time_picker_page.dart';

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
                builder: (context, state) => const ItemEditorPage(),
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
        builder: (context, state) => const ItemDetailPage(),
      ),
      GoRoute(
        path: AppRoutePaths.timePicker,
        builder: (context, state) => const TimePickerPage(),
      ),
    ],
  );
});
