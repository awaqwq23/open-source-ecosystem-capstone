import 'package:flutter/material.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsCourseGridPage extends StatelessWidget {
  const SettingsCourseGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isZh = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(
          context,
          title: isZh ? '课程方格模式设置' : 'Course Grid Settings',
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          children: [
            SettingsFlatSection(
              title: isZh ? '课程表导入' : 'Course Import',
              children: [
                SettingsFlatTile(
                  title: isZh ? '武汉大学教务系统' : 'WHU Academic System',
                  subtitle: isZh
                      ? '通过内嵌网页登录并导入课程'
                      : 'Import via embedded web login',
                  leading: const Icon(AppIcons.web),
                  onTap: () => context.openSecondary(
                    AppRoutePaths.campusTimetableImportWhu,
                  ),
                ),
                SettingsFlatTile(
                  title: isZh ? 'Wakeup 分享口令/链接' : 'Wakeup Share Link/Code',
                  subtitle: isZh ? '从分享文本导入课程表' : 'Import from shared text',
                  leading: const Icon(AppIcons.import),
                  onTap: () => context.openSecondary(
                    AppRoutePaths.campusTimetableImportWakeup,
                  ),
                ),
              ],
            ),
            SettingsFlatTile(
              title: isZh ? '课程表管理' : 'Timetable Management',
              leading: const Icon(Icons.table_chart_outlined),
              onTap: () =>
                  context.openSecondary(AppRoutePaths.campusTimetableManage),
            ),
          ],
        ),
      ),
    );
  }
}
